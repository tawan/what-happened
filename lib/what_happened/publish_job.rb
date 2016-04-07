module WhatHappened
  class PublishJob < ActiveJob::Base
    queue_as do
      WhatHappened.config.queue_name
    end

    def perform(event)
      all_topics = WhatHappened.config.all_topics
      applying_topics = all_topics.select { |t| t.applies?(event) }
      applying_topics.each { |t| t.publish!(event) }
    end
  end
end
