set :deploy_to, "/home/deployer/#{fetch(:application)}/staging"
set :rails_env, 'staging'
set :branch, 'staging'