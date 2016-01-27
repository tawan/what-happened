class BroadcastJob < ActiveJob::Base
  queue_as do
    Rails.application.config.x.what_happened.queue_name
  end

  def perform(version)
    Rails.application.config.x.what_happened.broadcast(version)
  end
end
