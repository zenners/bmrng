#Boomerang Proof

Here are some short notes on this repository. They are not necessarly complete as they are just a
"brain dump".

## Development
The code base is devoloped on Ruby 2.1.2 and Ruby on Rails 4.0.3, which can be found in .ruby-version and Gemfile respectivly. Some common comments I write to myself during development
are tagged with CHRISDO, BUGBUG, REVIEW. There should not be very many of these but worth checking for the in the code.

## Configuration
Application configuration can be found in config/application.yml except Stripe and Email which are configured as an initializer (config/initializers/stripe.rb and config/initializers/setup_mail.rb).

## Deployment
Deployment is conducted using Capistrano (v. 3.2.1). There are two stages "production", and "staging". These are connected to their respective branches in the repo.

## Server Config
The server is a basic Ubuntu Linux setup with Ruby, Ruby on Rails, Apache, Passenger for web
content delivery with a MySql backend. The MySql root password is 05test05.
