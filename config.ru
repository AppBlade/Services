require 'rubygems'
require 'bundler'

Bundler.require(:default)

require './services'

use Services
run Sinatra::Application
