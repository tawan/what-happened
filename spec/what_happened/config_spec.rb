require 'spec_helper'

describe WhatHappened::Config do
  subject(:config) { WhatHappened::Config.new }

  describe "#queue_name" do
    it "returns a default queue name" do
      expect(config.queue_name).to eq(:default)
    end
  end
end
