class CreateIntialStripeSubscription < ActiveRecord::Migration
  def change
    plan = Stripe::Plan.retrieve('default')
    unless plan
      Stripe::Plan.create(
        :amount => 30,
        :interval => 'month',
        :name => 'Boomerang Proof Subscription',
        :currency => 'usd',
        :id => 'default'
      )
    end
  end
end
