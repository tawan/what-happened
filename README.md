# What Happened

[![Build Status](https://travis-ci.org/tawan/what-happened.svg?branch=master)](https://travis-ci.org/tawan/what-happened)

## Installation

1. Add *What Happened* to your `Gemfile`.

    ```ruby
    gem 'what_happened', :git => 'https://github.com/tawan/what-happened.git', :branch => 'master'
    ```

1. Add a `versions` and `notifications` table to your database.

    ```bash
    bundle exec rails generate paper_trail:install --with-changes
    bundle exec rails generate what_happened:install
    bundle exec rake db:migrate
    ```

## Usage

```ruby
# config/notification_routing.rb
creating_membership do
  sends_notification :one_of_your_groups_has_a_new_member do
    to { |membership| membership.group.members }
    except_if { |recipient, membership| recipient.id == membership.user_id}
  end

  sends_notification :group_has_new_member do
    to { |membership| membership.group }
    except_if { |recipient, membership| membership.organizer }
  end
end

updating_group do
  skip_attributes(:created_at, :updated_at)

  sends_notification :group_was_renamed do
    to { |group| [ group.members, group ] }
  end
end
```

Notifications can be disabled with following config setting:
```ruby
Rails.application.configure do
  # ..
  config.what_happened.disabled = true
end
```
