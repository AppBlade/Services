require File.expand_path('../../services', __FILE__)
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class Service::TestCase < Test::Unit::TestCase

	def default_test
	end

	def crash_report_payload
    {
			'settings' => settings_payload,
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
			'settings' => settings_payload,
			'simple' => {
				'project'  => 'Test app',
				'version'  => '1.0.2',
				'platform' => 'Android',
				'user'     => 'James Daniels'
			},
			'url' => 'http://www.google.com'
		}
  end

	def settings_payload
		{
			'Service::Github' => {
				'api_token'        => 'xxxxxxxxxxxxxx',
				'username'         => 'jamesdaniels',
				'project'          => 'AppBlade/Services',
				'tag_for_crash'    => 'Crash',
				'tag_with_version' => true
			},
			'Service::Campfire' => {
				'api_token' => 'aaaaaaaa',
				'subdomain' => 'appblade',
				'room_name' => 'AppBlade',
				'sound'     => 'secret'
			}
		}
	end

end
