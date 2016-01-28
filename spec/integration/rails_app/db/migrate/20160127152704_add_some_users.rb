class AddSomeUsers < ActiveRecord::Migration
  def change
    Rails.application.config.x.what_happened.mute do
      [ "Linda", "Dave", "Monica", "John" ].each do |u|
        User.create(name: u)
      end
    end
  end
end
