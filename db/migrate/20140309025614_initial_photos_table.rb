class InitialPhotosTable < ActiveRecord::Migration
  def change
    create_table :photos, force: true do |p|
      p.integer :album_id
      p.integer :user_id
      p.string  :photo
      p.string  :photo_file_name
      p.string  :photo_content_type
      p.integer :photo_file_size
      p.timestamps
    end
  end
end
