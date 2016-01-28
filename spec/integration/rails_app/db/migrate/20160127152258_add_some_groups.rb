class AddSomeGroups < ActiveRecord::Migration
  def change
    Rails.application.config.x.what_happened.mute do
      [ "Ruby Meetup", "Snowboad Enthusiasts", "Railscamp", "Chess Club" ].each do |n|
        Group.create(name: n)
      end
    end
  end
end
