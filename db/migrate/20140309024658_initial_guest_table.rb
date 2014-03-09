class InitialGuestTable < ActiveRecord::Migration
  def change
    create_table :guests, force: true do |g|
      g.string    :name
      g.integer   :album_id
      g.string    :album_url
      g.string    :guest_id
      g.integer   :sign_in_count
      g.datetime  :current_sign_in_at
      g.datetime  :last_sign_in_at
      g.string    :current_sign_in_ip
      g.string    :last_sign_in_ip
      g.timestamps
    end
  end
end
