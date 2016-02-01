class AddSomeUsers < ActiveRecord::Migration
  def change
    WhatHappened.config.mute do
      [ "Linda", "Dave", "Monica", "John" ].each do |u|
        User.create(name: u)
      end
    end
  end
end
