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
      recipients = []
      @subscribers.each do |s|
        item = version.item.present? ? version.item : version.reify
        recipient = s.recipient(item)
        label = s.label
        if recipient.respond_to?(:each)
          recipient.each do |r|
            unless recipients.include?(r)
              Notification.create(version: version, recipient: r, label: label)
              recipients << r
            end
          end
        else
          unless recipients.include?(recipient)
            Notification.create(version: version, recipient: recipient, label: label)
            recipients << recipient
          end
        end
      end
    end
  end
end
