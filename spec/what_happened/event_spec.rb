require 'spec_helper'

describe WhatHappened::Event do
  let(:model_class) { double("message_class") }
  let(:event_name) { "create" }
  let(:subscribers) { [ ] }
  let(:event) { WhatHappened::Event.new(model_class, event_name, subscribers) }
  let(:version) { double("version") }
  let(:model_instance) { double("model_instance") }

  before do
    allow(version).to receive(:item) { model_instance }
    allow(WhatHappened::Notification).to receive(:create)
  end

  describe "#event_name" do
    subject { event.event_name }

    it { is_expected.to eq(event_name) }
  end

  describe "#fires?" do
    subject { event.fires?(model_class, current_event_name) }
    context "when model_class and event name match" do
      let(:current_event_name) { event_name }
      let(:current_model_class) { message_class }

      it { is_expected.to be true }
    end

    context "when current event name differs from event's event name" do
      let(:current_event_name) { "update" }

      it { is_expected.to be false }
    end
  end

  describe "#fire" do
    subject { event.fire(version) }
    let(:recipient) { double("recipient") }
    let(:subscribers) do
      [ lambda { |model_instance| model_instance.recipient } ]
    end

    before do
      allow(model_instance).to receive(:recipient) { recipient }
    end

    it "creates a notification for each subscriber" do
      expect(WhatHappened::Notification).to receive(:create).with(
        hash_including(version: version, recipient: recipient)
      )
      subject
    end
  end

  describe "#add_subscriber" do
    subject { event.add_subscriber(subscriber) }
    let(:subscriber) { double("subscriber") }

    it "adds subscriber" do
      expect(subscriber).to receive(:call).with(model_instance)
      subject
      event.fire(version)
    end
  end
end
