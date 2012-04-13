require 'test/unit'
require File.expand_path('../../lib/service', __FILE__)

class Service::TestCase < Test::Unit::TestCase

	def default_test
	end

end

Dir["#{File.dirname(__FILE__)}/../services/**/*.rb"].each { |service| load service }
