set :deploy_to, "/var/www/#{fetch(:application)}/production"
set :rails_env, 'production'
set :branch, 'master'
