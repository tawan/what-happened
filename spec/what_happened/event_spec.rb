require 'spec_helper'

describe WhatHappened::Event do
  let(:model_name) { :message }
  let(:version) { double("version") }
  let(:model_instance) { double("model instance") }
  let(:notifications_in_dsl) { Proc.new {} }
  let(:recipient) { double("recipient") }

  subject(:event) { WhatHappened::Event.new(model_name, notifications_in_dsl) }

  before do
    allow(version).to receive(:item) { model_instance }
    allow(model_instance).to receive(:recipient) { recipient }
  end

  describe "#fire" do
    it "arms the event with given version" do
      expect(event).to receive(:arm).with(version)
      event.fire(version)
    end

    it "evaluates notification declarations" do
      expect(event).to receive(:eval_notifications)
      event.fire(version)
    end
  end

  describe "#arm" do
    it "sets the current model instance" do
      event.send(:arm, version)
      expect(event.send(:model_instance)).to eq(model_instance)
    end
  end

  describe "#eval_notifications" do
    it "evaluates given notifications Proc object in instance context" do
      expect(event).to receive(:instance_eval)
      event.fire(version)
    end
  end

  describe "#notify" do
    it "creates a notification" do
      expect(WhatHappened::Notification).to receive(:create).
        with(hash_including(version: version, recipient: recipient))
      event.send(:arm, version)
      event.send(:notify, recipient)
    end
  end

  describe "DSL support" do
    let(:notifications_in_dsl) do
      Proc.new do
        notifies message.recipient
      end
    end

    before do
      allow(WhatHappened::Notification).to receive(:create)
    end
    
    it "responds to the model_name" do
      expect { event.send(model_name) }.not_to raise_error
    end

    it "notifies recipient" do
      expect(event).to receive(:notify).with(recipient)
      event.fire(version)
    end
  end
end
