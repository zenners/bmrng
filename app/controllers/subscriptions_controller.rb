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
end