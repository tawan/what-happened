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
        model_class = model.to_s.camelize.constantize
        track_update(model_class, @produced_subscribers, @skip_attributes)
      end

      def destroying(model, event_specification)
        run_event_specification(event_specification)
        track_destroy(model.to_s.camelize.constantize, @produced_subscribers)
      end

      def skip_attributes(*attributes)
        @skip_attributes = attributes.flatten
      end
      alias :skip_attribute :skip_attributes

      def queue_as(queue_name)
        @queue_name = queue_name
      end

      def sends_notification(label, &subscriber_specifiation)
        subscriber = WhatHappened::Subscriber.new(label)
        subscriber.instance_eval(&subscriber_specifiation)
        @produced_subscribers << subscriber
      end

      private

      def run_event_specification(event_specification)
        @produced_subscribers = [ ]
        @skip_attributes = nil
        instance_eval(&event_specification)
      end
    end
  end
end
