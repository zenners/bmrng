set :deploy_to, "/var/www/#{fetch(:application)}/staging"
set :rails_env, 'staging'
set :branch, 'beta'