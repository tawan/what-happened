module WhatHappenedHelper
  def render_notifications(notifications, *args)
    notifications.reduce('') { |buffer, n| buffer << render_notification(n, *args) }.html_safe
  end

  def render_notification(notification, *args)
    changed_attributes = notification.event.changeset.keys.reduce([]) { |sum, key| sum << key; sum << key.to_sym }
    render(
      partial: "what_happened/#{notification.label}",
      locals: {
        notification.event.item_type.tableize.singularize.to_sym => notification.event.item,
        recipient: notification.recipient, changed_attributes: changed_attributes
      }).html_safe
  end
end
