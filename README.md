# What Happened

[![Build Status](https://travis-ci.org/tawan/what-happened.svg?branch=master)](https://travis-ci.org/tawan/what-happened)


## Usage

```ruby
# config/notification_routing.rb
specify do
  creating_group_membership do
    sends_notification :one_of_your_groups_has_a_new_member do
      to { |group_membership| group_membership.group.users }
    end

    sends_notification :group_has_new_member do
      to { |group_membership| group_membership.group }
    end
  end
end
```
