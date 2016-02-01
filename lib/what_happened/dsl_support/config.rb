module WhatHappened
  module DSLSupport
    class Subscriber
      attr_reader :label

      def initialize(label)
        @label = label
        @condition_callbacks = [ Proc.new { true } ]
      end

      def recipient(item)
        @recipient_callback.call(item)
      end

      def except_if(&condition_callback_inversed)
        @condition_callbacks << Proc.new do |*args|
          !condition_callback_inversed.call(*args)
        end
      end

      def only_if(&condition_callback)
        @condition_callbacks << condition_callback
      end

      def to(&recipient_callback)
        @recipient_callback = recipient_callback
      end

      def conditions(recipient = nil, item = nil)
        @condition_callbacks.each do |c|
          return false unless c.call(recipient, item)
        end
        true
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

      def sends_notification(label, &subscriber_specifiation)
        subscriber = Subscriber.new(label)
        subscriber.instance_eval(&subscriber_specifiation)
        @produced_subscribers << subscriber
      end

      private

      def run_event_specification(event_specification)
        @produced_subscribers = [ ]
        instance_eval(&event_specification)
      end
    end
  end
end
