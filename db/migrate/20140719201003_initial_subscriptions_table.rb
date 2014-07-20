class InitialSubscriptionsTable < ActiveRecord::Migration
  def change
    create_table :subscriptions, force: true do |s|
      s.integer :user_id
      s.string :stripe_subscription_token
      s.string :status
      s.timestamps
    end
  end
end
