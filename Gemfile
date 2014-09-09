source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.3'
gem 'capistrano', '>= 3.2'#, require: false, group: :debugger
gem 'capistrano-bundler', '~> 1.1.2'#, require: false, group: :debugger
gem 'capistrano-rails', '~> 1.1'#, require: false, group: :debugger
gem 'net-ssh', '>= 2.9.1'#, require: false, group: :debugger #2.9.1 fixes auth issue
gem 'activerecord-session_store', github: 'rails/activerecord-session_store'

# Use mysql as the database for Active Record
gem 'mysql2'

group :assets do
  # Use SCSS for stylesheets
  gem 'sass-rails', '~> 4.0.0'
  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'
  # Use CoffeeScript for .js.coffee assets and views
  gem 'coffee-rails', '~> 4.0.0'
end

gem "devise" #, ">= 2.2.3"
gem "cancan" #, ">= 1.6.9"
gem "rolify" #,        :git => "git://github.com/EppO/rolify.git"
gem "simple_form"
gem "stripe" #, ">= 1.7.11"
gem "stripe_event" #, ">= 0.4.0"
gem 'rmagick'
gem 'fancybox2-rails'
gem 'impressionist', github: 'Loremaster/impressionist'
gem 'masonry-rails'
gem 'paperclip'
gem 'protected_attributes' #TODO: this is a hack gem to allow attr_accessible
gem 'jquery-fileupload-rails'
gem 'figaro' #TODO: Instead of in source this should be a system file
#gem 'bootstrap-sass'
gem 'better_errors'
gem 'binding_of_caller'
gem 'dropzonejs-rails'
gem 'acts_as_follower'
gem 'aws-sdk'
gem 'paperclip-meta'
gem "nested_form"

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
gem 'byebug', group: [:development, :test]
