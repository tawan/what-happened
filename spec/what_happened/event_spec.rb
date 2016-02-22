require 'spec_helper'

describe WhatHappened::Event do
  let(:model_class) { double("message_class") }
  let(:event_name) { "create" }
  let(:subscribers) { [ ] }
  let(:event) { WhatHappened::Event.new(model_class, event_name, subscribers) }
  let(:version) { double("version") }
  let(:model_instance) { double("model_instance") }
  let(:subscriber) { double("subscriber") }
  let(:recipient) { double("recipient") }
  let(:item_type) { double("item_type") }

  before do
    allow(version).to receive(:item) { model_instance }
    allow(version).to receive(:item_type) { item_type }
    allow(item_type).to receive(:constantize) { model_class }
    allow(version).to receive(:event) { event_name }
    allow(WhatHappened::Notification).to receive(:create)
    allow(subscriber).to receive(:recipients) { recipient }
    allow(subscriber).to receive(:label) { :default }
    allow(subscriber).to receive(:conditions) { true }
  end

  describe "#event_name" do
    subject { event.event_name }

    it { is_expected.to eq(event_name) }
  end

  describe "#fires?" do
    subject { event.fires?(version) }
    context "when model_class and event name match" do
      it { is_expected.to be true }
    end

    context "when current event name differs from event's event name" do
      before { allow(version).to receive(:event) { "update" } }
      it { is_expected.to be false }
    end

    context "when current model class differs from event's model class" do
      before do
        allow(version).to receive(:item_type) { double("other class").as_null_object }
      end
      it { is_expected.to be false }
    end
  end

  describe "#fire" do
    subject { event.fire(version) }
    let(:subscribers) do
      [ subscriber ]
    end

    before do
      allow(model_instance).to receive(:recipients) { recipient }
    end

    it "creates a notification for each subscriber" do
      expect(WhatHappened::Notification).to receive(:create).with(
        hash_including(version: version, recipient: recipient)
      )
      subject
    end

    context "when condition callback resolves to false" do
      before do
        allow(subscriber).to receive(:conditions) { false }
      end

      it "does not create a notification" do
        expect(WhatHappened::Notification).not_to receive(:create).with(
          hash_including(version: version, recipient: recipient)
        )
        subject
      end
    end

    context "when recipient responds to :each" do
      before do
        allow(model_instance).to receive(:recipients) { [ recipient ] }
      end

      it "creates a notification for each subscriber" do
        expect(WhatHappened::Notification).to receive(:create).with(
          hash_including(version: version, recipient: recipient)
        )
        subject
      end
    end

    context "when multiple subscribers resolve to identical recipient" do
      let(:subscriber_2) { double("subscriber") }
      let(:subscribers) do
        [ subscriber, subscriber_2 ]
      end

      before do
        allow(subscriber_2).to receive(:recipients) { recipient }
        allow(subscriber_2).to receive(:label) { :default }
        allow(subscriber_2).to receive(:conditions) { true }
      end

      it "creates only one notification" do
        expect(WhatHappened::Notification).to receive(:create).with(
          hash_including(version: version, recipient: recipient)
        ).exactly(1).times
        subject
      end
    end
  end

  describe "#add_subscriber" do
    subject { event.add_subscriber(subscriber) }

    it "adds subscriber" do
      expect(subscriber).to receive(:recipients).with(model_instance)
      expect(subscriber).to receive(:label)
      subject
      event.fire(version)
    end
  end

  describe "#skip_attributes" do
    let(:skipped_attributes) { [ :created_at, :updated_at ] }
    let(:event_name) { "update" }

    before do
      allow(version).to receive(:changeset) { changeset }
      event.skip_attributes(*skipped_attributes)
    end

    subject { event.fires?(version) }

    context "when skipped_attributes is an array" do
      let(:skipped_attributes) { [ [:created_at, :updated_at] ] }
      let(:changeset) { { "created_at" => [], "updated_at" => [] } }

      it { is_expected.to be false }
    end

    context "when skipped attributes include all changed attributes" do
      let(:changeset) { { "created_at" => [], "updated_at" => [] } }
      it { is_expected.to be false }
    end

    context "when skipped attributes intersects with changed_attributes" do
      let(:changeset) { { "created_at" => [], "name" => [] } }
      it { is_expected.to be true }
    end

    context "when skipped attributes does not overlap with changed_attributes" do
      let(:changeset) { { "name" => [] } }
      it { is_expected.to be true }
    end
  end
end
