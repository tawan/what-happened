module WhatHappened
  class Subscriber
    include WhatHappened::DSLSupport::Subscriber

    def initialize(label)
      @label = label
      @condition_callbacks = [ Proc.new { true } ]
    end

    def accept_version(version)
      item = version.item.present? ? version.item : version.reify
      recipients(item).each do |r|
        if conditions(r, item)
          Notification.create(version: version, recipient: r, label: @label)
        end
      end
    end

    private

    def recipients(item)
      @recipient_callbacks.reduce([]) { |b, c| b << c.call(item) }.flatten
    end

    def conditions(recipient = nil, item = nil)
      @condition_callbacks.each do |c|
        return false unless c.call(recipient, item)
      end
      true
    end
  end
end
