class AddSomeGroups < ActiveRecord::Migration
  def change
    [ "Ruby-Dojo", "Snowboad Enthusiasts", "Railscamp" ].each do |n|
      Group.create(name: n)
    end
  end
end
