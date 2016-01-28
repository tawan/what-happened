class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer  :version_id,   :null => false
      t.integer  :recipient_id, :null => false
      t.string   :recipient_type, :null => false
      t.string   :label
      t.timestamps
    end
  end
end
