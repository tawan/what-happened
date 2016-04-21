FactoryGirl.define do
  factory :user, aliases: [:creator] do
    name "John"
  end

  factory :message do
    text "Hi wie geht's?"
  end

  factory :group do
    name "Ruby Meetup"
  end

  factory :membership do
    user
    group
  end

  factory :meeting do
    name "Monthly meetup"
    creator
    group
  end

  factory :member, parent: :user do
    transient do
      group create(:group)
    end

    after(:create) do |member, evaluator|
      create(:membership, user: member, group: evaluator.group)
    end
  end

  factory :participant, parent: :user do
    transient do
      meeting create(:meeting)
    end

    after(:create) do |participant, evaluator|
      create(:participation, user: participant, meeting: evaluator.meeting)
    end
  end

  factory :participation do
    user
    meeting
  end
end
