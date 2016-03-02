class CreateEvents < ActiveRecord::Migration
  TEXT_BYTES = 1_073_741_823

  def change
    create_table :events, versions_table_options do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.text     :changeset, :text, limit: TEXT_BYTES
      t.datetime :created_at
    end
    add_index :events, [:item_type, :item_id]
  end
end
