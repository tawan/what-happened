require 'what_happened/config_registry'

module WhatHappened
  def self.config=(config)
    @config = config
  end

  def self.config
    if ConfigRegistry.config
      return ConfigRegistry.config
    else
      return @config
    end
  end
end

require 'active_job'
require 'what_happened/version'
require 'what_happened/dsl_support/dsl_support'
require 'what_happened/subscriber'
require 'what_happened/config'
require 'what_happened/topic'
require 'what_happened/event'
require 'what_happened/notification'
require 'what_happened/model_concern'
require 'what_happened/publish_job'
require 'what_happened/railtie' if defined? Rails
