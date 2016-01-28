class AddSomeUsers < ActiveRecord::Migration
  def change
    [ "Linda", "Dave", "Donald Trump", "Sokrates" ].each do |u|
      User.create(name: u)
    end
  end
end
