# config/notification_routing.rb
creating_membership do
  sends_notification :one_of_your_groups_has_a_new_member do
    to { |membership| membership.group.users }
    except_if { |recipient, membership| recipient.id == membership.user_id}
  end

  sends_notification :group_has_new_member do
    to { |membership| membership.group }
    except_if { |recipient, membership| membership.organizer }
  end
end
