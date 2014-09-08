# config valid only for Capistrano 3.2.1
lock '3.2.1'

def current_git_branch
  $git_branch ||= begin
    branch = `git symbolic-ref HEAD 2> /dev/null`.strip.gsub(/^refs\/heads\//, '')
    puts "Deploying branch #{branch}"
    branch
  end
end

def default_stage_from_git
  ({"master"=>"production", "beta"=>"staging"}[current_git_branch]) || current_git_branch
end

set :application, 'boom'
set :repo_url, 'git@bitbucket.org:boomerangproof/bmrng.git'
set :branch, current_git_branch
set :deploy_via, :remote_cache
set :rails_env, default_stage_from_git
set :test_log, "log/capistrano.test.log"
set :stages, %w(alpha staging production)
set :default_stage, default_stage_from_git
set :user, 'www-data'
set :password, ask('Server password',nil)
set :keep_releases, 3

role :web, 'web.boomerangproof.com'
role :app, 'web.boomerangproof.com'
role :db,  'db.boomerangproof.com', :primary => true

#The server command must be below the definition of roles. This is to fix
#authentication where otherwise connection is attempted with 'user'
server 'web.boomerangproof.com', user:fetch(:user), password:fetch(:password), roles:%w{web app db}
# Default branch is :master
#ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{log public/system public/assets tmp/pids}
# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  # only allow a deploy with passing tests to deployed
  #before :deploy, "deploy:run_tests"

  # compile assets locally then rsync
  #after 'deploy:symlink:shared', 'compile_assets:compile_assets_locally'

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :finishing, 'deploy:cleanup'

  after :publishing, :restart

  task :start do
    invoke 'delayed_job:start'
  end

  task :restart do
    invoke 'delayed_job:restart'
  end

  task :stop do
    invoke 'delayed_job:stop'
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
