class AddCurrentPeriodToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :stripe_current_period_end, :string
  end
end
