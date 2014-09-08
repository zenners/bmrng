set :deploy_to, "/var/www/#{fetch(:application)}/alpha"
set :rails_env, 'alpha'
set :branch, 'alpha'