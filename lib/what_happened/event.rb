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
        item = version.item.present? ? version.item : version.reify
        recipient = s.recipient(item)
        label = s.label
        if recipient.respond_to?(:each)
          recipient.each do |r|
            Notification.create(version: version, recipient: r, label: label)
          end
        else
          Notification.create(version: version, recipient: recipient, label: label)
        end
      end
    end
  end
end
