require 'active_record'
module WhatHappened
  class Notification < ActiveRecord::Base
    belongs_to :event, class_name: "WhatHappened::Event"
    belongs_to :recipient, polymorphic: true
  end
end
