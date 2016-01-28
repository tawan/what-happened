module WhatHappened
  module DSLSupport
    class Subscriber
      attr_accessor :label

      def initialize(recipient_callback, label = nil)
        @recipient_callback = recipient_callback
        self.label = label
      end

      def recipient(item)
        @recipient_callback.call(item)
      end
    end

    module Config
      extend ActiveSupport::Concern

      def specify(&specification)
        instance_eval(&specification)
      end

      def method_missing(methodId, *args, &spec)
        if m = methodId.to_s.match(/\Acreating_(.+)\z/)
          creating(m[1], spec)
        elsif m = methodId.to_s.match(/\Aupdating_(.+)\z/)
          updating(m[1], spec)
        elsif m = methodId.to_s.match(/\Adestroying_(.+)\z/)
          destroying(m[1], spec)
        else
          super
        end
      end

      def notifies(&recipient_callback)
        @produced_subscribers << Subscriber.new(recipient_callback)
      end

      def creating(model, event_specification)
        run_event_specification(event_specification)
        track_create(model.to_s.camelize.constantize, @produced_subscribers)
      end

      def updating(model, event_specification)
        run_event_specification(event_specification)
        track_update(model.to_s.camelize.constantize, @produced_subscribers)
      end

      def destroying(model, event_specification)
        run_event_specification(event_specification)
        track_destroy(model.to_s.camelize.constantize, @produced_subscribers)
      end

      def queue_as(queue_name)
        @queue_name = queue_name
      end

      def label_as(label)
        @produced_subscribers.last.label = label
      end

      private

      def run_event_specification(event_specification)
        @produced_subscribers = [ ]
        instance_eval(&event_specification)
      end
    end
  end
end
