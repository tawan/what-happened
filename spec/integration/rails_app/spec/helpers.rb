module Helpers
  def mount_new_what_happened_config
    config = WhatHappened::Config.new
    Rails.application.config.x.what_happened = config
    config
  end
end
