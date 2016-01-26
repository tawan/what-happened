require 'spec_helper'

describe WhatHappened::Config do
  subject(:config) { WhatHappened::Config.new }
  let(:message_class) { double("message_class") }

  before do
    allow(message_class).to receive(:paper_trail_enabled_for_model?)
    allow(message_class).to receive(:has_paper_trail)
    allow(message_class).to receive(:paper_trail_options) { { on: [ ] } }
  end

  describe "events tracker" do
    describe "#track_create" do
      it "starts a paper trail" do
        expect(message_class).to receive(:has_paper_trail).with(hash_including(on: [ :create ]))
        config.track_create(message_class)
      end
    end
  end

  describe "#queue_name" do
    it "returns a default queue name" do
      expect(config.queue_name).to eq(:default)
    end
  end

  describe "#broadcast" do
    let(:version) { double("version") }
    let(:event) { double("event") }
    let(:item) { double("item") }

    before do
      allow(event).to receive(:fires?) { true }
      allow(WhatHappened::Event).to receive(:new) { event }
      allow(version).to receive(:item) { item }
      allow(item).to receive(:class) { message_class }
      allow(version).to receive(:event) { "create" }
      config.track_create(message_class)
    end

    it "fires events" do
      expect(event).to receive(:fire).with(version)
      config.broadcast(version)
    end
  end
end
