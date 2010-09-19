set :application, 'readme-this'

set :user, 'rich'
set :ssh_flags, '-A'

set :repository, 'git://github.com/RichGuk/readme-this.git'

set :domain, "#{user}@carina.27smiles.com"
set :deploy_to, "/home/rich/apps/#{application}"

set :perm_owner, 'rich'
set :perm_group, 'nginx'
set :umask, '027'
set :shared_paths, { 'log' => 'log' }

set :rvm_path, '$HOME/.rvm'

namespace :vlad do
  desc 'Install gem from Gemfile'
  remote_task :bundle do

    rvm_setup = "source #{rvm_path}/scripts/rvm && rvm rvmrc trust #{current_path}"
    bundle_update = "bundle install --without test development"
    run "#{rvm_setup} && cd #{current_path} && #{bundle_update}"
  end

  task :update do
    Rake::Task['vlad:bundle'].invoke
  end

  remote_task :update_symlinks, :roles => :app do
    run "rm #{release_path}/config.ru && ln -s #{shared_path}/config.ru #{release_path}/config.ru"
  end

  desc 'Deploy the latest application and restart the server'
  task :deploy => [:update, :start_app]
end
