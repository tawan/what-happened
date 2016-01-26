module WhatHappened
  module DSLSupport
    module Config
      extend ActiveSupport::Concern

      def specify(&specification)
        instance_eval(&specification)
      end

      def method_missing(methodId, *args, &spec)
        if m = methodId.to_s.match(/\Acreating_(.+)\z/)
          creating(m[1], spec)
        else
          super
        end
      end

      def notifies(&subscriber)
        @produced_subscribers ||= [ ]
        @produced_subscribers << subscriber
      end

      def creating(model, event_specification)
        @produced_subscribers = [ ]
        instance_eval(&event_specification)
        track_create(model.to_s.camelize.constantize, @produced_subscribers)
      end

      def queue_as(queue_name)
        @queue_name = queue_name
      end
    end
  end
end
