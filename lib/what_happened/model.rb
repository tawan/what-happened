module WhatHappened
  module Model
    extend ActiveSupport::Concern

    def what_happened(since = nil)
      s = Notification.where(recipient: self)
      unless since.nil?
        s = s.where(["created_at >= ?", since ])
      end
      s
    end
  end
end
