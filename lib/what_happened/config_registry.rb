require 'active_support/per_thread_registry'

module WhatHappened
  class ConfigRegistry
    extend ActiveSupport::PerThreadRegistry

    attr_accessor :config
  end
end
