require 'spec_helper'

describe WhatHappened::Config do
  let(:definition) { Proc.new {} }
  subject(:config) { WhatHappened::Config.new &definition }
  let(:message_class) { double("message_class") }

  before do
    allow(message_class).to receive(:paper_trail_enabled_for_model?)
    allow(message_class).to receive(:has_paper_trail)
    allow(message_class).to receive(:paper_trail_options) { { on: [ ] } }
    stub_const("Message", message_class)
  end

  describe "create update destroy callbacks" do
    describe "#creating" do
      let(:definition) do
        Proc.new do
          creating :message do
            notifies message.recipient, of: :new_message_in_inbox
          end
        end
      end

      it "adds a create event" do
        expect(config.events[:create]).to_not be_empty
        expect(config.events[:create][:message]).to_not be_empty
      end

      it "starts a paper trail" do
        expect(message_class).to receive(:has_paper_trail).with(hash_including(on: [ :create ]))
        config
      end
    end
  end

  describe "#queue_name" do
    it "returns a default queue name" do
      expect(config.queue_name).to eq(:default)
    end

    context "when definiation declares a queue name" do
      let(:definition) do
        Proc.new { queue_as :other_name }
      end

      it "returns declared queue name" do
        expect(config.queue_name).to eq(:other_name)
      end
    end
  end

  describe "#broadcast" do
    let(:event_name) { "create" }
    let(:version) { double("version") }
    let(:item) { double("item") }
    let(:item_class) { double("item_class") }
    let(:item_class_name) { "Message" }
    let(:event) { double("event") }
    let(:stubbed_events) do
      h = HashWithIndifferentAccess.new
      h[event_name] = HashWithIndifferentAccess.new
      h[event_name][:message] = [ event ]
      h
    end

    before do
      allow(version).to receive(:event) { event_name }
      allow(version).to receive(:item) { item }
      allow(item).to receive(:class) { item_class }
      allow(item_class).to receive(:name) { item_class_name }

      allow(config).to receive(:events) { stubbed_events }
    end

    it "fires events" do
      expect(event).to receive(:fire).with(version)
      config.broadcast(version)
    end
  end
end
