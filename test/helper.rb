require 'test/unit'
require File.expand_path('../../lib/service', __FILE__)

class Service::TestCase < Test::Unit::TestCase

	def default_test
	end

	def crash_report_payload
    {
			'settings' => {
				'api_token' => 'aaaaaaaa',
				'subdomain' => 'appblade',
				'room_name' => 'AppBlade',
				'sound' => 'secret'
			},
			'simple' => {
				'project' => 'Test app',
				'version' => '1.0.2',
				'message' => 'test error'
			},
			'url' => 'http://www.google.com'
		}
  end

end

Dir["#{File.dirname(__FILE__)}/../services/**/*.rb"].each { |service| load service }
