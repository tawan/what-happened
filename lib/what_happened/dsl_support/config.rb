module WhatHappened
  module DSLSupport
    module Config
      extend ActiveSupport::Concern

      def specify(&specification)
        instance_eval(&specification)
      end

      def method_missing(methodId, *args, &spec)
        if m = methodId.to_s.match(/\Acreating_(.+)\z/)
          specifify_topic(m[1], :create, spec)
        elsif m = methodId.to_s.match(/\Aupdating_(.+)\z/)
          specifify_topic(m[1], :update, spec)
        elsif m = methodId.to_s.match(/\Adestroying_(.+)\z/)
          specifify_topic(m[1], :destroy, spec)
        else
          super
        end
      end

      def skip_attributes(*attributes)
        @current_topic.skip_attributes(attributes.flatten)
      end
      alias :skip_attribute :skip_attributes

      def queue_as(queue_name)
        @queue_name = queue_name
      end

      def sends_notification(label, &subscriber_specifiation)
        subscriber = WhatHappened::Subscriber.new(label)
        subscriber.instance_eval(&subscriber_specifiation)
        @current_topic.add_subscriber(subscriber)
      end

      private

      def specifify_topic(model, event_type, subscriber_specification)
        model_class = model.to_s.camelize.constantize
        @current_topic = find_or_create_topic(event_type, model_class )
        instance_eval(&subscriber_specification)
      end
    end
  end
end
