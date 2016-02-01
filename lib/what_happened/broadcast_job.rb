class BroadcastJob < ActiveJob::Base
  queue_as do
    WhatHappened.config.queue_name
  end

  def perform(version)
    WhatHappened.config.broadcast(version)
  end
end
