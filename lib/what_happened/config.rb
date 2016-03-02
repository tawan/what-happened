module WhatHappened
  class Config
    attr_reader :queue_name

    include WhatHappened::DSLSupport::Config

    def initialize
      @events =  [ ]
      @queue_name = :default
      @topics = { }
    end

    def topic(model_class, event_name)
      @topics[model_class] ||= { }
      @topics[model_class][event_name] ||= Topic.new(model_class,event_name)
    end

    def all_topics
      t = @topics.values
      return [ ] if t.empty?
      t.collect(&:values).flatten
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

    def append_paper_trail
      all_topics.each do |topic|
        unless topic.model_class.paper_trail_enabled_for_model?
          topic.model_class.has_paper_trail :on => []
        end
        tracked_events = (topic.model_class.paper_trail_options[:on] << topic.event_name).uniq
        topic.model_class.has_paper_trail :on => tracked_events
      end
    end

    def hook_into_active_record_cycle
      callback, *args = if Rails.application.config.what_happened.after_commit
        [:after_commit, { on: :create }]
      else
        ["after_create".to_sym ]
      end

      PaperTrail::Version.send(callback, *args) do |version|
        config = WhatHappened.config
        config.all_topics.select { |t| t.applies?(version) }.each do |topic|
          topic.publish(version)
        end
      end
    end
  end
end
