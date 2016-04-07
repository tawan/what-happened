module WhatHappened
  class Topic
    attr_reader :event_type, :model_class

    def initialize(model_class, event_type)
      @model_class = model_class
      @event_type = event_type
      @subscribers = [ ]
      @skip_attributes = [ ]
    end

    def add_subscriber(subscriber)
      @subscribers << subscriber
    end

    def publish!(event)
      unless applies?(event)
        raise(RuntimeError, <<-MSG)
          Event #{event} does not apply for #{self}
        MSG
      end

      publish(event)
    end

    def publish(event)
      return unless applies?(event)

      @subscribers.each do |s|
        s.accept_version(event)
      end
    end

    def applies?(event)
      return false unless event.item.kind_of?(@model_class)
      return false unless event.event_type.to_sym == self.event_type
      if event_type == :update
        changed_attributes = event.changeset.keys.collect(&:to_s)
        return false if (changed_attributes - @skip_attributes).empty?
      end
      return true
    end

    def skip_attributes(*attributes)
      @skip_attributes = attributes.flatten.collect(&:to_s)
    end

    def to_s
      "<Topic model_class:#{@model_class.name}, event_type:#{@event_type}>"
    end
  end
end
