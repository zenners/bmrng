class InitialAlbumTable < ActiveRecord::Migration
  def change
    create_table :albums, force: true do |a|
      a.integer :user_id
      a.string  :name
      a.string  :title
      a.boolean :social, default: false
      a.boolean :watermark, default: false
      a.boolean :password_toggle, default: false
      a.string  :password
      a.timestamps
    end
  end
end
