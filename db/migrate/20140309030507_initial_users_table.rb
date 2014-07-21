class InitialUsersTable < ActiveRecord::Migration
  def change
    create_table :users, force: true do |u|
      u.string :name
      u.string :human_name
      u.string :studio_name
      u.string :watermark_image
      u.string :link
      u.string :email, null: false
      u.string :stripe_customer_token
      u.string :last_4_digits
      u.string :status
      u.timestamps
    end
    add_attachment :users, :logo
  end
end
