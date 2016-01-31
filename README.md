# What Happened

[![Build Status](https://travis-ci.org/tawan/what-happened.svg?branch=master)](https://travis-ci.org/tawan/what-happened)


## Usage

```ruby
# config/notification_routing.rb
specify do
  creating_group_membership do
    notifies { |group_membership| group_membership.group.users }
    label_as :one_of_your_groups_has_a_new_member

    notifies { |group_membership| group_membership.group }
    label_as :group_has_new_member
  end

  creating_comment do
    notifies { |comment| comment.commentable.users }
    only_if { |comment| comment.commentable.is_a? Group }
    only_if { |comment| comment.creator_id == comment.commentable.organizer_id }
    label_as :new_comment_in_group

    notifies { |comment| comment.commentable.users }
    only_if { |comment| comment.commentable.is_a? Group }
    label_as :new_comment_in_group
  end
end
```
