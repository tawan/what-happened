class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :memberships do |t|
      t.integer :user_id
      t.integer :group_id
      t.boolean :organizer, default: false
      t.timestamps null: false
    end
  end
end
