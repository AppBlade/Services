require 'rubygems'
require 'bundler'

Bundler.require(:default)

require './services'

run Sinatra::Application
