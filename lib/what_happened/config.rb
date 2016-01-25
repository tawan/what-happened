require 'active_support'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext'

module WhatHappened
  class Config
    attr_reader :events, :queue_name

    def initialize(&definition)
      @events = HashWithIndifferentAccess.new
      @queue_name = :default
      instance_eval(&definition)
    end

    def creating(model, &notifications)
      events[:create] ||= ActiveSupport::HashWithIndifferentAccess.new
      events[:create][model] ||= []
      events[:create][model] << Event.new(model, notifications)
      model_class = model.to_s.camelize.constantize
      paper_trail_on_create(model_class)
    end

    def queue_as(queue_name)
      @queue_name = queue_name
    end

    def broadcast(version)
      triggering_events(version).each do |event|
        event.fire(version)
      end
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
end
