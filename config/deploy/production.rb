set :deploy_to, "/home/deployer/#{fetch(:application)}/production"
set :rails_env, 'production'
set :branch, 'master'