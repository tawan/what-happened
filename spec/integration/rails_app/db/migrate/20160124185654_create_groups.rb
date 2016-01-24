class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :group_memberships do |t|
      t.integer :user_id
      t.integer :group_id
    end
  end
end
