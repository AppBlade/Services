require 'rvm/capistrano'
require 'bundler/capistrano'
require 'capistrano_colors'

set :rvm_ruby_string, 'ruby-1.9.3-p362'
set :rvm_type, :user

ssh_options[:forward_agent] = true

set :application, 'Services'
set :repository,  'git@github.com:AppBlade/Services.git'
set :deploy_via,   :remote_cache
set :copy_exclude, %w(.git test spec features)
set :scm,          :git
set :use_sudo,     false

set :branch, 'master'

role :web, '184.106.81.128'
role :app, '184.106.81.128'
role :db,  '184.106.81.128', :primary => true

set :user,        'appblade'
set :deploy_to,   "/home/#{user}/#{application}"
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
	  run "cd #{previous_release} && kill `cat services.pid`" if File.exists? "#{previous_release}/services.pid"
    run "cd #{current_path} && bundle exec ruby services.rb >> services.log 2>&1 &"
	end

end
