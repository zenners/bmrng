class RegistrationsController < Devise::RegistrationsController

  before_filter :configure_permitted_parameters

  def new
    super
  end

  def create
    sub_params = params[:user].delete(:subscription)
    @user = User.new(params[:user].merge(status: :created))
    if @user.save
      #Create the subscription
      sub = Subscription.new(sub_params.merge(user_id: @user.id))
      if sub.save_with_payment
        sign_in @user, :bypass => true
        redirect_to after_sign_up_path_for(@user)
      end
    end
    render :new
  end

  def update_plan
    @user = current_user
    role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil?
    if @user.update_plan(role)
      redirect_to edit_user_registration_path, :notice => 'Updated plan'
    else
      flash.alert = 'Unable to update plan'
      render :edit
    end
  end

  def update_card
    @user = current_user
    @user.stripe_token = params[:user][:stripe_token]
    if @user.save
      redirect_to edit_user_registration_path, :notice => 'Updated card'
    else
      flash.alert = 'Unable to update card'
      render :edit
    end
  end

  def update
    # required for settings form to submit when password is left blank
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    @user = User.find(current_user.id)
    if @user.update_attributes(params[:user])
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  protected
  # my custom fields are :name, :stripe_token
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :stripe_token,
        :email, :password, :password_confirmation)
    end
    devise_parameter_sanitizer.for(:user_update) do |u|
      u.permit(:name,
        :email, :password, :password_confirmation, :current_password)
    end
  end

  private
  def build_resource(*args)
    super
    if params[:plan]
      resource.add_role(params[:plan])
    end
  end

end
