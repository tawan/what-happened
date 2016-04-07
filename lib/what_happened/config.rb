module WhatHappened
  class Config
    attr_reader :queue_name

    include WhatHappened::DSLSupport::Config

    def initialize
      @events =  [ ]
      @queue_name = :default
      @topics = [ ]
    end

    def find_or_create_topic(event_type, model_class)
      topic = nil
      filtered = find_topics(event_type, model_class)
      if filtered.empty?
        topic =  Topic.new(model_class, event_type)
        @topics << topic
      else
        topic = filtered.first
      end
      topic
    end

    def find_topics(event_type, model_class = nil)
      filtered = @topics.select { |t| t.event_type == event_type }
      unless model_class.nil?
        filtered = filtered.select { |t| t.model_class == model_class }
      end
      filtered
    end

    def all_topics
      @topics
    end

    def disabled?
      @disabled ||= false
    end

    def disabled
      was_disabled = disabled?
      @disabled = true
      yield
      @disabled = was_disabled
    end

    def hook_into_active_record_cycle
      [:create, :update].each do |event_type|
        topics = find_topics(event_type)
        next if topics.empty?
        topics.each do |topic|
          if Rails.application.config.what_happened.after_commit
            topic.model_class.after_commit "publish_#{event_type}".to_sym, on: event_type
          else
            topic.model_class.send("after_#{event_type}".to_sym, "publish_#{event_type}".to_sym)
          end
        end
      end
    end
  end
end
