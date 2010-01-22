set :application, "readme-this"
set :repository,  "git://github.com/RichGuk/readme-this.git"

set :deploy_to, "~/apps/#{application}"

set :scm, :git
set :git_shallow_clone, 1
set :git_enable_submodules, 1
set :deploy_via, :remote_cache
set :branch, 'master'
set :repository_cache, "#{application}-src"
set :key_relesaes, 3
set :use_sudo, false
# set :ssh_options, :forward_agent => true

set :user, 'rich'

role :app, "readme-this.27smiles.com"
role :web, "readme-this.27smiles.com"
role :db,  "readme-this.27smiles.com", :primary => true

after "deploy:finalize_update", "deploy:rackup"

namespace :deploy do
  desc "restart passenger app"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Copy config.ru from shared path to current path (for example config.ru with DATABASE_URL information)"
  task :rackup do
    run "cp #{shared_path}/config.ru #{current_path}/config.ru"
  end
end