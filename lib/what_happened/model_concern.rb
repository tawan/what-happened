module WhatHappened
  module ModelConcern
    extend ActiveSupport::Concern

    def publish_update
      publish_event("update")
    end

    def publish_create
      publish_event("create")
    end

    def what_happened(since = nil)
      s = Notification.where(recipient: self)
      unless since.nil?
        s = s.where(["created_at >= ?", since ])
      end
      s
    end

    def publish_event(event_type)
      all_topics = WhatHappened.config.all_topics
      changeset = JSON.dump(changes)
      event =  WhatHappened::Event.new(
        item: self, event_type: event_type, changeset: changeset)
      applying_topics = all_topics.select { |t| t.applies?(event) }
      return if applying_topics.empty?
      event.save!
      PublishJob.perform_later(event)
    end
  end
end
