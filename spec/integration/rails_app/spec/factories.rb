FactoryGirl.define do
  factory :user do
    name "John"
  end

  factory :message do
    text "Hi wie geht's?"
  end

  factory :group do
    name "Ruby Meetup"
  end

  factory :group_membership do
    user
    group
    organizer false
  end
end
