class AddSessionsTable < ActiveRecord::Migration
  def change
    create_table :sessions, force: true do |t|
      t.string :session_id, :null => false, default: 'null'
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id, :unique => true
    add_index :sessions, :updated_at
  end
end
