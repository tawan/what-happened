require 'spec_helper'

describe WhatHappened::DSLSupport::Config do
  let(:config) { WhatHappened::Config.new }
  let(:message_class) { double("message_class").as_null_object }
  let(:specification) do
    Proc.new do
      creating_message do
        notifies { |message| message.recipient }
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

  describe "notifies" do
    it "creates a subscriber" do
      config.specify &specification
      expect(WhatHappened::Notification).to receive(:create).with(
        hash_including(version: version, recipient: recipient)
      )
      config.broadcast(version)
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

  describe "label_as" do
    let(:specification) do
      Proc.new do
        creating_message do
          notifies { |message| message.recipient }
          label_as :new_message
        end
      end
    end

    it "labels notification" do
      expect(WhatHappened::Notification).to receive(:create).with(
        hash_including(version: version, recipient: recipient, label: :new_message)
      )
      config.specify &specification
      config.broadcast(version)
    end
  end
end
