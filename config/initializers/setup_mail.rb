ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
    :address => 'smtp.gmail.com',
    :port => 587,
    :domain => 'aquatic-edge.com',
    :authentication => 'plain',
    :user_name => 'chris@aquatic-edge.com',
    :password => '05test05',
    :enable_starttls_auto => true
}
