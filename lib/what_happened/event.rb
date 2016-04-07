require 'active_record'

module WhatHappened
  class Event < ActiveRecord::Base
    belongs_to :item, :polymorphic => true

    def changeset
      @changeset ||= JSON.parse(read_attribute(:changeset))
    end
  end
end
