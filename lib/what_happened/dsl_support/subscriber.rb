module WhatHappened
  module DSLSupport
    module Subscriber
      extend ActiveSupport::Concern

      def to(&recipient_callback)
        @recipient_callbacks ||= [ ]
        @recipient_callbacks << recipient_callback
      end

      def except_if(&condition_callback_inversed)
        @condition_callbacks << Proc.new do |*args|
          !condition_callback_inversed.call(*args)
        end
      end

      def only_if(&condition_callback)
        @condition_callbacks << condition_callback
      end
    end
  end
end
