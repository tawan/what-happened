module WhatHappened
  class Subscriber
    attr_reader :label

    include WhatHappened::DSLSupport::Subscriber

    def initialize(label)
      @label = label
      @condition_callbacks = [ Proc.new { true } ]
    end

    def recipient(item)
      @recipient_callbacks.reduce([]) { |b, c| b << c.call(item) }.flatten
    end

    def conditions(recipient = nil, item = nil)
      @condition_callbacks.each do |c|
        return false unless c.call(recipient, item)
      end
      true
    end
  end
end
