class AddSomeMemberships < ActiveRecord::Migration
  def change
    Rails.application.config.x.what_happened.mute do
      users = User.all.to_a
      Group.all.each do |g|
        Membership.create(user: users.pop, group: g, organizer: true)
      end
    end
  end
end
