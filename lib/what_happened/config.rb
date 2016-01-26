module WhatHappened
  class Config
    attr_reader :queue_name

    include WhatHappened::DSLSupport::Config

    def initialize
      @events =  [ ]
      @queue_name = :default
    end

    def track_create(model_class, event_subscribers = nil)
      paper_trail_on_create(model_class)
      @events << Event.new(model_class, :create, event_subscribers)
    end

    def broadcast(version)
      triggering_events(version).each do |event|
        event.fire(version)
      end
    end

    private

    def triggering_events(version)
      @events.select { |e| e.fires?(version.item.class, version.event) }
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