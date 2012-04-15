require 'test/unit'
require File.expand_path('../../lib/service', __FILE__)

class Service::TestCase < Test::Unit::TestCase

	def default_test
	end

	def crash_report_payload
    {
			'settings' => self.class::SettingsPayload,
			'simple' => {
				'project'  => 'Test app',
				'version'  => '1.0.2',
				'message'  => 'test error',
				'platform' => 'iPhone'
			},
			'url' => 'http://www.google.com'
		}
  end

	def new_version_payload
		{
			'settings' => self.class::SettingsPayload,
			'simple' => {
				'project' => 'Test app',
				'version' => '1.0.2',
				'message' => 'test error',
				'user'    => 'James Daniels'
			},
			'url' => 'http://www.google.com'
		}
  end

end

Dir["#{File.dirname(__FILE__)}/../services/**/*.rb"].each { |service| load service }
