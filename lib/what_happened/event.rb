module WhatHappened
  class Event
    attr_reader :event_name, :subscribers

    def initialize(model_class, event_name, subscribers = [ ])
      @model_class = model_class
      @event_name = event_name
      @subscribers = subscribers
    end

    def fires?(version)
      return false unless version.item_type.constantize == @model_class
      version.event == self.event_name.to_s
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
        unless recipient.respond_to?(:each)
          recipient = [ recipient ]
        end
        recipient.each do |r|
          unless recipients.include?(r) || !s.conditions(r, item)
            Notification.create(version: version, recipient: r, label: label)
            recipients << r
          end
        end
      end
    end
  end
end
