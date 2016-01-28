class AddSomeMemberships < ActiveRecord::Migration
  def change
    Group.first.users << User.first
    Group.last.users << User.last
  end
end
