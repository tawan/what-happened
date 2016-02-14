class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.integer :group_id, index: true
      t.integer :creator_id, index: true
      t.string :name
      t.text :description
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps null: false
    end

    create_table :participations do |t|
      t.integer :meeting_id, index: true
      t.integer :user_id, index: true
    end
  end
end
