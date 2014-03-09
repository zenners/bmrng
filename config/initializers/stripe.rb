Stripe.api_key = "sk_test_N9jcRhTJ0pQB78HtSOpAs3Jf"
STRIPE_PUBLIC_KEY = "pk_test_8cuWJKwYw2wM893BTHEPP4Ty"

StripeEvent.setup do
  subscribe 'customer.subscription.deleted' do |event|
    user = User.find_by_customer_id(event.data.object.customer)
    user.expire
  end
end