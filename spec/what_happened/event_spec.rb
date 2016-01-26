require 'spec_helper'

describe WhatHappened::Event do
  let(:model_class) { double("message_class") }
  let(:event_name) { "create" }
  let(:subscribers) { [ ] }
  let(:event) { WhatHappened::Event.new(model_class, event_name, subscribers) }
  let(:version) { double("version") }
  let(:model_instance) { double("model_instance") }
  let(:recipient) { double("recipient") }
  let(:recipient_class) { double("recipient_class").as_null_object }
  let(:subscribers) do
    [ lambda { |model_instance| model_instance.recipient } ]
  end

  before do
    allow(version).to receive(:item) { model_instance }
    allow(WhatHappened::Notification).to receive(:create)
    allow(model_instance).to receive(:recipient) { recipient }
    allow(recipient).to receive(:class) { recipient_class }
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

    it "creates a notification for each subscriber" do
      expect(WhatHappened::Notification).to receive(:create).with(
        hash_including(version: version, recipient: recipient)
      )
      subject
    end

    it "adds notification association to recipient class" do
      expect(recipient_class).to receive(:has_many).with(
        :notifications, hash_including(
          as: :recipient,
          class_name: "WhatHappened::Notification"
        )
      )
      subject
    end
  end
end
