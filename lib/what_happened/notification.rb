require 'active_record'
module WhatHappened
  class Notification < ActiveRecord::Base
    belongs_to :version, class_name: "PaperTrail::Version"
    belongs_to :recipient, polymorphic: true
  end
end
