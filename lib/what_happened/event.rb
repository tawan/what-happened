module WhatHappened
  class Event
    def initialize(model_name, notifications)
      @model_name = model_name
      @notifications = notifications
    end

    def fire(version)
      arm(version)
      eval_notifications
    end

    def method_missing(methodId, *args)
      if methodId == @model_name
        @model_instance
      else
        super
      end
    end

    private

    attr_reader :model_instance

    def arm(version)
      @model_instance = version.item
      @version = version
    end

    def eval_notifications
      instance_eval(&@notifications)
    end

    def notify(recipient)
      Notification.create(version: @version, recipient: recipient)
    end

    def notifies(recipient)
      notify(recipient)
    end
  end
end
