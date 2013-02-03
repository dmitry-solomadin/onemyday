require "bundler/capistrano"

set :application, "onemyday"
set :repository,  "git@github.com:znvPredatoR/onemyday"
set :scm, "git"
set :user, "root"
set :scm_passphrase, "thequaker1"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "78.47.164.71"                          # Your HTTP server, Apache/etc
role :app, "78.47.164.71"
role :db, "78.47.164.71", :primary => true

set :deploy_to,   "/data/#{application}"
set :deploy_via, :remote_cache
set :use_sudo,    false

default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }

namespace :starter do
  desc "Own deploy folder"
  task :prepare, :roles => :app do
    #run "cd #{release_path} && cd .. && chown -R root:root ."
    run "cd #{current_path}/config && chmod +x onemyday-starter"
  end

  desc "Start the application services"
  task :start, :roles => :app do
    run "cd #{current_path}/config && bash script onemyday-starter start"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    run "cd #{current_path}/config && bash script onemyday-starter stop"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    run "cd #{current_path}/config && ./onemyday-starter restart"
  end
end

namespace :deploy do
  desc "Compile assets"
  task :precompile_assets, :roles => :app do
    run "cd #{current_path} && bundle exec rake assets:precompile --trace"
  end

  desc "Migrate db"
  task :migrate_db, :roles => :app do
    run "cd #{current_path} && bundle exec rake db:migrate --trace"
  end
end

after 'deploy:create_symlink', 'deploy:precompile_assets'
after 'deploy:precompile_assets', 'deploy:migrate_db'
after 'deploy:update', 'starter:prepare'
after 'deploy:update', 'starter:restart'

require './config/boot'

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end