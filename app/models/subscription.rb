class Subscription < ActiveRecord::Base
  attr_accessible :user_id, :stripe_subscription_token, :stripe_current_period_end, :plan
  attr_accessor :stripe_card_token, :plan

  belongs_to :user

  def self.available_plans
    plans = Stripe::Plan.all
    plans.map{|p| [p.name, p.id]}
  end

  def save_with_payment
    if valid?
      customer = Stripe::Customer.create(description: user_id, plan: plan, card: stripe_card_token)
      user.update stripe_customer_token: customer.id
      self.stripe_subscription_token = customer.subscriptions.first.id
      self.stripe_current_period_end = Time.at(customer.subscriptions.first.current_period_end)
      save!
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end

  def update_with_payment
    if valid?
      customer = Stripe::Customer.retrieve(user.stripe_customer_token)
      sub = customer.subscriptions.retrieve(stripe_subscription_token)
      sub.card = stripe_card_token
      sub.save
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while updating credit card: #{e.message}"
    errors.add :base, 'There was a problem with your credit card.'
    false
  rescue Stripe::CardError => e
    logger.error "Stripe error updating subscription: #{id}, Error: #{e}"
    errors.add :base, 'There was a problem with your credit card.'
    false
  end

  def update_plan(role)
    self.role_ids = []
    self.add_role(role.name)
    unless stripe_customer_id.nil?
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      customer.update_subscription(:plan => role.name)
    end
    true
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to update your subscription. #{e.message}."
    false
  end

  def update_stripe
    return if Rails.env.development?
    return if email.include?('@example.com') and not Rails.env.production?
    if stripe_customer_id.nil?
      if !stripe_token.present?
        raise "Stripe token not present. Can't create account."
      end
      if coupon.blank?
        customer = Stripe::Customer.create(
          :email => email,
          :description => name,
          :card => stripe_token,
          :plan => roles.first.name
        )
      else
        customer = Stripe::Customer.create(
          :email => email,
          :description => name,
          :card => stripe_token,
          :plan => roles.first.name,
          :coupon => coupon
        )
      end
    else
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      if stripe_token.present?
        customer.card = stripe_token
      end
      customer.email = email
      customer.description = name
      customer.save
    end
    self.last_4_digits = customer.cards.data.first["last4"]
    self.stripe_customer_id = customer.id
    self.stripe_token = nil
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "#{e.message}."
    self.stripe_token = nil
    false
  end

  def cancel_subscription
    unless stripe_customer_id.nil?
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      unless customer.nil? or customer.respond_to?('deleted')
        if customer.subscription.status == 'active'
          customer.cancel_subscription
        end
      end
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to cancel your subscription. #{e.message}."
    false
  end

  def expire
    UserMailer.expire_email(self).deliver
    destroy
  end

end