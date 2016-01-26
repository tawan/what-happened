module WhatHappened
  class Event
    attr_reader :event_name, :subscribers

    def initialize(model_class, event_name, subscribers = [ ])
      @model_class = model_class
      @event_name = event_name
      @subscribers = subscribers
    end

    def fires?(model_class, event_name)
      return false unless model_class == @model_class
      event_name.to_s == self.event_name.to_s
    end

    def add_subscriber(subscriber)
      @subscribers << subscriber
    end

    def fire(version)
      @subscribers.each do |s|
        recipient = s.call(version.item)
        Notification.create(version: version, recipient: recipient)
      end
    end
  end
end