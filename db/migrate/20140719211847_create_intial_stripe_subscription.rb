class CreateIntialStripeSubscription < ActiveRecord::Migration
  def change
    plan = Stripe::Plan.retrieve('month')
    unless plan
      Stripe::Plan.create(
        :amount => 30,
        :interval => 'month',
        :name => 'Monthly - $30/mo',
        :currency => 'usd',
        :id => 'month'
      )
    end
    plan = Stripe::Plan.retrieve('year')
    unless plan
      Stripe::Plan.create(
        :amount => 330,
        :interval => 'year',
        :name => 'Yearly - $330/yr',
        :currency => 'usd',
        :id => 'year'
      )
    end
  end
end
