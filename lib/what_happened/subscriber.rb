module WhatHappened
  class Subscriber
    include WhatHappened::DSLSupport::Subscriber

    def initialize(label)
      @label = label
      @condition_callbacks = [ Proc.new { true } ]
    end

    def accept_version(event)
      item = event.item
      recipients(item).each do |r|
        if conditions(r, item)
          n = Notification.create(event: event, recipient: r, label: @label)
          changed_attributes = n.event.changeset.keys.reduce([]) { |sum, key| sum << key; sum << key.to_sym }
          NotificationsChannel.broadcast_to(r,
            notification: ApplicationController.render(
              partial: "what_happened/#{n.label}",
              locals: {
                n.event.item_type.tableize.singularize.to_sym => n.event.item,
                recipient: n.recipient, changed_attributes: changed_attributes
              }).html_safe)
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
