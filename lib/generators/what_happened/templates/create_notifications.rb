class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer  :recipient_id, :null => false
      t.string   :recipient_type, :null => false
      t.string   :label
      t.timestamps :null => false
    end
    add_reference :notifications, :event, index: true
    add_index :notifications, [ :recipient_type, :recipient_id ]
  end
end
