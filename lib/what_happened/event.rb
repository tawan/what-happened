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

    def fire(version)
      @subscribers.each do |s|
        recipient = s.call(version.item)
        Notification.create(version: version, recipient: recipient)
        unless recipient.respond_to?(:notifications)
          add_notification_assocation(recipient.class)
        end
      end
    end

    private

    def add_notification_assocation(klass)
      klass.has_many(
        :notifications,
        as: :recipient,
        class_name: "WhatHappened::Notification"
      )
    end
  end
end
