#Boomerang Proof

Here are some short notes on this repository. They are not necessarly complete as they are just a
"brain dump".

## Development
The code base is devoloped on Ruby 2.1.2 and Ruby on Rails 4.0.3, which can be found in .ruby-version and Gemfile respectivly. Some common comments I write to myself during development
are tagged with CHRISDO, BUGBUG, REVIEW. There should not be very many of these but worth checking for the in the code.

  ### Amazon AWS
  S3 is used for image storage from clients. The api configuration can be found in the application.yml file. Most of this is handled by Paperclip (amazing Gem) that handles all the uploading automatically. You may want to review how to cache images if the amount of bandwidth from S3 becomes and issue (largest expense of their service).

  ### Paperclip
  This is a great plugin that handles the storage handling of all images from clients, include galleries and logos.

  ### ImageMagik
  This is a great gem that handles all the image resizing and can do so much more then currently used for. Further tweaking of this will be prudent to ensure best use of storage and bandwidth with S3. Configuration is mainly on a per model basis through the paperclip setup.

## Configuration
Application configuration can be found in config/application.yml except Stripe and Email which are configured as an initializer (config/initializers/stripe.rb and config/initializers/setup_mail.rb).

## Deployment
Deployment is conducted using Capistrano (v. 3.2.1). There are two stages "production", and "staging". These are connected to their respective branches in the repo.

## Server Config
The server is a basic Ubuntu Linux setup with Ruby, Ruby on Rails, Apache, Passenger for web
content delivery with a MySql backend. The MySql root password is 05test05.
