# config/what_happened.rb
specify do
  creating_group_membership do
    notifies { |group_membership| group_membership.group.user }
    notifies { |group_membership| group_membership.group }
  end
end
