class AddSomeGroups < ActiveRecord::Migration
  def change
    Rails.application.config.x.what_happened.mute do
      [ "Ruby-Dojo", "Snowboad Enthusiasts", "Railscamp" ].each do |n|
        Group.create(name: n)
      end
    end
  end
end
