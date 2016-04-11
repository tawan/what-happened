class AddSomeGroups < ActiveRecord::Migration
  def change
    WhatHappened.config.disabled do
      [ "Ruby Meetup", "Snowboard Enthusiasts", "Railscamp", "Chess Club" ].each do |n|
        Group.create(name: n)
      end
    end
  end
end
