ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
    :address => 'smtpout.secureserver.net',
    :port => 465,
    :domain => 'boomerangproof.com',
    :authentication => 'plain',
    :user_name => 'chris@boomerangproof.com',
    :password => '05test05',
    :enable_starttls_auto => true
}
