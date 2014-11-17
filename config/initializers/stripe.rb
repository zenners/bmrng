#REVIEW: These should be in application.yml
if Rails.env.development?
  Stripe.api_key = "sk_test_yfsRj3fGXlTOybn5j56OWNvF"
  STRIPE_PUBLIC_KEY = "pk_test_HqAK6GT66wFTl6EGLqFRzHcy"
end
if Rails.env.production? or Rails.env.staging?
  Stripe.api_key = "sk_live_UyCk8CQd1HvLZjzO0Cs06GEX"
  STRIPE_PUBLIC_KEY = "pk_live_GpRpRJm5lLT9gh9GIvNKW6Cr"
end

StripeEvent.setup do
  subscribe 'customer.subscription.deleted' do |event|
    user = User.find_by_customer_id(event.data.object.customer)
    user.expire
  end
end