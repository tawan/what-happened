module WhatHappenedHelper
  def render_notifications(notifications, *args)
    notifications.reduce('') { |buffer, n| buffer << render_notification(n, *args) }
  end

  def render_notification(notification, *args)
    changed_attributes = notification.version.changeset.keys.reduce([]) { |sum, key| sum << key; sum << key.to_sym }
    render(
      partial: "what_happened/#{notification.label}",
      locals: {
        notification.version.item_type.tableize.singularize.to_sym => notification.version.item,
        recipient: notification.recipient, changed_attributes: changed_attributes
      })
  end
end
