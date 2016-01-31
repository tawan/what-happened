# config/notification_routing.rb
specify do
  creating_group_membership do
    notifies { |group_membership| group_membership.group.users }
    label_as :one_of_your_groups_has_a_new_member

    notifies { |group_membership| group_membership.group }
    label_as :group_has_new_member
  end
end