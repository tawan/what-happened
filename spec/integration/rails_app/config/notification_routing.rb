# config/notification_routing.rb
creating_membership do
  sends_notification :group_has_new_member do
    to { |membership| membership.group }
  end
end

creating_meeting do
  sends_notification :new_meeting_announced do
    to { |meeting| meeting.group.users }

    except_if { |recipient, meeting| recipient == meeting.creator }
  end
end

updating_meeting do
  skip_attributes(:description, :updated_at)

  sends_notification :meeting_was_updated do
    to { |meeting| meeting.participants }
  end
end
