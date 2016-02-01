require 'spec_helper'

describe WhatHappened::DSLSupport::Config do
  let(:config) { WhatHappened::Config.new }
  let(:message_class) { double("message_class").as_null_object }
  let(:specification) do
    Proc.new do
      creating_message do
        sends_notification :new_message_in_inbox do
          to { |message| message.recipient }
        end
      end
    end
  end
  let(:version) { double("version") }
  let(:item) { double("item") }
  let(:recipient) { double("recipient") }

  before do
    stub_const("Message", message_class)
    allow(version).to receive(:item) { item }
    allow(version).to receive(:item_type) { "Message" }
    allow(version).to receive(:event) { "create" }
    allow(item).to receive(:recipient) { recipient }
    allow_any_instance_of(WhatHappened::Event).to receive(:fires?) { true }
  end

  describe "creating_*" do
    it "tracks create events of model class" do
      expect(config).to receive(:track_create).with(message_class, anything)
      config.specify &specification
    end
  end

  describe "sends_notification" do
    it "creates a subscriber" do
      config.specify &specification
      expect(WhatHappened::Notification).to receive(:create).with(
        hash_including(
          version: version,
          recipient: recipient,
          label: :new_message_in_inbox
        )
      )
      config.broadcast(version)
    end

    describe "except_if" do
      let(:specification) do
        Proc.new do
          creating_message do
            sends_notification :new_message_in_inbox do
              to { |message| message.recipient }
              except_if { |recipient, message| true }
            end
          end
        end
      end

      it "adds a condition_callback to subscriber" do
        config.specify &specification
        expect(WhatHappened::Notification).not_to receive(:create).with(
          hash_including(
            version: version,
            recipient: recipient,
            label: :new_message_in_inbox
          )
        )

        config.broadcast(version)
      end
    end

    describe "only_if" do
      let(:specification) do
        Proc.new do
          creating_message do
            sends_notification :new_message_in_inbox do
              to { |message| message.recipient }
              only_if { |recipient, message| false }
            end
          end
        end
      end

      it "adds a condition_callback to subscriber" do
        config.specify &specification
        expect(WhatHappened::Notification).not_to receive(:create).with(
          hash_including(
            version: version,
            recipient: recipient,
            label: :new_message_in_inbox
          )
        )

        config.broadcast(version)
      end
    end
  end

  describe "queue_as" do
    let(:specification) do
      Proc.new { queue_as :other_name }
    end

    it "returns declared queue name" do
      config.specify &specification
      expect(config.queue_name).to eq(:other_name)
    end
  end
end
