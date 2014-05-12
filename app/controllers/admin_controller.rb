class AdminController < ApplicationController
  before_filter :authenticate_user!

  def become
    session[:admin_id] = current_user.id if current_user.admin?
    return unless current_user.admin? or session[:admin_id]
    if params[:id]
      if params[:id].to_i > 0
        sign_in(:user, User.find(params[:id]))
      elsif a = User.find_by_email(params[:id])
        sign_in(:user, a)
      end
    end
    redirect_to root_url # or user_root_url
  end
end
