module WhatHappened
  class Event
    attr_reader :event_name, :subscribers

    def initialize(model_class, event_name, subscribers = [ ])
      @model_class = model_class
      @event_name = event_name
      @subscribers = subscribers
      @skip_attributes = [ ]
    end

    def fires?(version)
      return false unless version.item_type.constantize == @model_class
      return false unless version.event == self.event_name.to_s
      if version.event == "update"
        changed_attributes = version.changeset.keys.collect(&:to_s)
        return false if (changed_attributes - @skip_attributes).empty?
      end
      true
    end

    def add_subscriber(subscriber)
      @subscribers << subscriber
    end

    def skip_attributes(*attributes)
      @skip_attributes = attributes.flatten.collect(&:to_s)
    end

    def fire(version)
      done = []
      @subscribers.each do |s|
        item = version.item.present? ? version.item : version.reify
        recipients = s.recipients(item)
        label = s.label
        unless recipients.respond_to?(:each)
          recipients = [ recipients ]
        end
        recipients.each do |r|
          unless done.include?(r) || !s.conditions(r, item)
            Notification.create(version: version, recipient: r, label: label)
            done << r
          end
        end
      end
    end
  end
end
