module WhatHappened
  def self.define(&definition)
    @@config = WhatHappened::Config.new
    @@config.instance_eval(&definition)
  end

  def self.config
    @@config
  end

  class Config
    class Event
      def initialize(model, notifications)
        @model = model
        @notifications = notifications
      end


      def fire(version)
        arm(version)
        instance_eval(&@notifications)
      end

      def method_missing(methodId)
        if methodId == @model
          @model_instance
        else
          super
        end
      end

      private

      def arm(version)
        @model_instance = version.item
        @version = version
      end

      def notifies(recipient, meta_data = {})
        if recipient.respond_to?(:each)
          recipient.each do |r|
            Notification.create(version: @version, recipient: r)
          end
        else
          Notification.create(version: @version, recipient: recipient)
        end
      end
    end

    attr_reader :events, :queue_name

    def initialize
      @events  = ActiveSupport::HashWithIndifferentAccess.new
      @queue_name = :default
    end

    def a_new(model, &notifications)
      @create ||= [ ]
      @create << model
      model_class = model.to_s.camelize.constantize
      paper_trail_on_create(model_class)
      events[:create] ||= ActiveSupport::HashWithIndifferentAccess.new
      events[:create][model] ||= []
      events[:create][model] << Event.new(model, notifications)
    end

    def broadcast(version)
      triggering_events(version).each do |event|
        event.fire(version)
      end
    end

    def queue_as(queue_name)
      @queue_name = queue_name
    end

    private

    def triggering_events(version)
      events[version.event][version.item.class.name.tableize.singularize]
    end

    def paper_trail_on_create(model_class)
      unless model_class.paper_trail_enabled_for_model?
        model_class.has_paper_trail :on => []
      end
      tracked_events = (model_class.paper_trail_options[:on] << :create).uniq
      model_class.has_paper_trail :on => tracked_events
    end
  end

  module InstanceMethods
    def notifications
      s = PaperTrail::Version.where(created_at >= last_checked)
      s = s.where(item_type: "Message")
    end

    def last_checked
      Time.now - 3.days
    end
  end

  class Notification < ActiveRecord::Base
    belongs_to :version, class_name: "PaperTrail::Version"
    belongs_to :recipient, polymorphic: true
  end

  module AfterPaperTrailVersionCreateCallback
    extend ActiveSupport::Concern

    included do
      after_create do |version|
        BroadcastJob.perform_later(version)
      end
    end
  end

  class BroadcastJob < ActiveJob::Base
    queue_as do
      WhatHappened.config.queue_name
    end

    def perform(version)
      WhatHappened.config.broadcast(version)
    end
  end
end

ActiveRecord::Base.include(WhatHappened::InstanceMethods)

PaperTrail::Version.include(WhatHappened::AfterPaperTrailVersionCreateCallback)

WhatHappened.define do
  queue_as :notifications

  a_new :message do
    notifies message.recipient, of: :new_message_in_inbox
  end

  a_new :group_membership do
    notifies group_membership.group.users, of: :new_member_in_group
  end
end
