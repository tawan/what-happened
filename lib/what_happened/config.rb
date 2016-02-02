module WhatHappened
  class Config
    attr_reader :queue_name

    include WhatHappened::DSLSupport::Config

    def initialize
      @events =  [ ]
      @queue_name = :default
    end

    def track_create(model_class, event_subscribers = nil)
      track(:create, model_class, event_subscribers)
    end

    def track_update(model_class, event_subscribers = nil)
      track(:update, model_class, event_subscribers)
    end

    def track_destroy(model_class, event_subscribers = nil)
      track(:destroy, model_class, event_subscribers)
    end

    def broadcast(version)
      unless mute?
        triggering_events(version).each do |event|
          event.fire(version)
        end
      end
    end

    def mute?
      @mute ||= false
    end

    def mute
      was_muted = mute?
      @mute = true
      yield
      @mute = was_muted
    end

    private

    def track(event_name, model_class, event_subscribers = nil)
      paper_trail_on(event_name, model_class)
      @events << Event.new(model_class, event_name, event_subscribers)
    end

    def triggering_events(version)
      @events.select { |e| e.fires?(version) }
    end

    def paper_trail_on(event_name, model_class)
      unless model_class.paper_trail_enabled_for_model?
        model_class.has_paper_trail :on => []
      end
      tracked_events = (model_class.paper_trail_options[:on] << event_name).uniq
      model_class.has_paper_trail :on => tracked_events
    end
  end
end
