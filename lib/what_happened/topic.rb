module WhatHappened
  class Topic
    attr_reader :event_name, :model_class

    def initialize(model_class, event_name)
      @model_class = model_class
      @event_name = event_name
      @subscribers = [ ]
      @skip_attributes = [ ]
    end

    def add_subscriber(subscriber)
      @subscribers << subscriber
    end

    def publish!(version)
      unless applies?(version)
        raise(RuntimeError, <<-MSG)
          Version #{version} does not apply for #{self}
        MSG
      end

      publish(version)
    end

    def publish(version)
      return unless applies?(version)

      @subscribers.each do |s|
        s.accept_version(version)
      end
    end

    def applies?(version)
      return false unless version.item_type.constantize == @model_class
      return false unless version.event == self.event_name.to_s
      if version.event == "update"
        changed_attributes = version.changeset.keys.collect(&:to_s)
        return false if (changed_attributes - @skip_attributes).empty?
      end
      return true
    end

    def skip_attributes(*attributes)
      @skip_attributes = attributes.flatten.collect(&:to_s)
    end

    def to_s
      "<Topic model_class:#{@model_class.name}, event_name:#{@event_name}>"
    end
  end
end
