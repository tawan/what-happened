# config/notification_routing.rb
specify do
  creating_group_membership do
    sends_notification :one_of_your_groups_has_a_new_member do
      to { |group_membership| group_membership.group.users }
      except_if { |recipient, group_membership| recipient.id == group_membership.user_id}
    end

    sends_notification :group_has_new_member do
      to { |group_membership| group_membership.group }
      except_if { |recipient, group_membership| group_membership.organizer }
    end
  end
end
