class AddSomeMemberships < ActiveRecord::Migration
  def change
    Rails.application.config.x.what_happened.mute do
      Group.first.users << User.first
      Group.last.users << User.last
    end
  end
end
