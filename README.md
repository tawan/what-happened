# What Happened

[![Build Status](https://travis-ci.org/tawan/what-happened.svg?branch=master)](https://travis-ci.org/tawan/what-happened)


## Usage

```ruby
# config/notification_routing.rb
specify do
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
end
```
