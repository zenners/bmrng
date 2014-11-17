class UserMailer < ActionMailer::Base
  default :from => "info@boomerangproof.com"
  
  def expire_email(user)
    mail(:to => user.email, :subject => "Subscription Cancelled")
  end

  def send_feedback(user, message)
    @message = message
    @user = user
    mail(
      :from => 'no-reply@boomerangproof.com',
      :to => 'nate@boomerangproof.com,chris@boomerangproof.com',
      :subject => "Feedback send for Boomerang Proof from #{user.human_name}",
      :headers => {}
    )
  end

  def request_support(user, message)
    @message = message
    @user = user
    mail(
        :from => 'no-reply@boomerangproof.com',
        :to => 'chris@boomerangproof.com',
        :subject => "SUPPORT REQUEST for Boomerang Proof from #{user.human_name}",
        :headers => {}
    )

  end
end