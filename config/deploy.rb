require 'rvm/capistrano'
require 'bundler/capistrano'
require 'capistrano_colors'

set :rvm_ruby_string, 'ruby-2.1.0-p0'
set :rvm_type, :user

ssh_options[:forward_agent] = true

set :application, 'Services'
set :repository,  'git@github.com:AppBlade/Services.git'
set :deploy_via,   :remote_cache
set :copy_exclude, %w(.git test spec features)
set :scm,          :git
set :use_sudo,     false

set :branch, 'master'

role :web, '23.253.35.161'
role :app, '23.253.35.161'
role :db,  '23.253.35.161', :primary => true

set :user,        'appblade'
set :deploy_to,   "/#{application}"
set :domain_name, '0.0.0.0'

before :deploy, 'deploy:check_revision'

namespace :deploy do

  desc "Make sure there is something to deploy"
  task :check_revision, :roles => [:web] do
    unless `git rev-parse #{branch}` == `git rev-parse origin/#{branch}`	
      puts ""
      puts "  \033[1;33m**************#{'*'*(branch.size*2)}**************************\033[0m"
      puts "  \033[1;33m* WARNING: #{branch} is not the same as origin/#{branch} *\033[0m"
      puts "  \033[1;33m**************#{'*'*(branch.size*2)}**************************\033[0m"
      puts ""
			puts "Continue with deploy? (y/n)"
			exit if STDIN.gets.strip != 'y'
    end
  end
	
	desc 'Restarting the service'
	task :restart, :roles => [:web] do
    run "cd #{current_path} && touch tmp/restart.txt"
	end

end
