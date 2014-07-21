class SubscriptionsController < ApplicationController

  def index
    redirect_to current_user
  end
  def new
    @subscription = Subscription.new(user_id: current_user.id)
  end

  def create
    @subscription = Subscription.new(params[:subscription])
    if @subscription.save_with_payment
      redirect_to current_user, :notice => 'Credit card processed successfully!' and return
    else
      render :new and return
    end
  end

  def edit
    @subscription = if flash[:model]
      flash[:model]
    else
      current_user.subscription
    end
  end

  def update
    @subscription = Subscription.find(params[:id])
    #Token comes from Stripe JS code through their API
    @subscription.stripe_card_token = params[:subscription][:stripe_card_token]
    if @subscription.update_with_payment
        redirect_to current_user, notice: 'Credit card updated successfully!' and return
    else
      #flash[:model] = @subscription
      render :edit and return # action: :edit
    end
  end

  def destroy
    resource.status = 'canceled'
    customer = Stripe::Customer.retrieve(resource.user.stripe_customer_token)
    customer.subscriptions.retrieve(resource.stripe_subscription_token).delete(at_period_end: true)
    resource.save
    redirect_to current_user, notice: "We are sorry to see you go! You subscription will end on #{resource.stripe_current_period_end.strftime("%m-%d-%Y")}"
  end

  def resource
    param = params['id']
    @subscription ||= Subscription.find(param)
  end
end