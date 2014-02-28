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
				'api_token'         => 'xxxxxxxxxxxxxx',
				'username'          => 'jamesdaniels',
				'project'           => 'AppBlade/Services',
				'tag_for_crash'     => 'Crash',
				'tag_with_version'  => '1',
				'tag_with_platform' => '1'
			},
			'Service::Campfire' => {
				'api_token' => 'aaaaaaaa',
				'subdomain' => 'appblade',
				'room_name' => 'AppBlade',
				'sound'     => 'secret'
			},
			'Service::Hipchat' => {
				'room'                   => 'appblade',
				'token'                  => 'aaaaaa',
				'crash_report_color'     => 'yellow',
				'feedback_color'         => 'green',
				'new_version_color'      => 'purple',
				'post_on_crash_report'   => '1',
				'post_on_feedback'       => '1',
				'post_on_new_version'    => '1',
				'notify_on_crash_report' => '1',
				'notify_on_feedback'     => '1',
				'notify_on_new_version'  => '0'
			},
			'Service::Bugzilla' => {
				'product'                 => 'appblade',
				'component'               => 'test',
				'feedback_priority'       => 'P4',
				'crash_report_priority'   => 'P4',
				'feedback_severity'       => 'normal',
				'crash_report_severity'   => 'normal',
				'create_bug_for_crashes'  => '1',
				'create_bug_for_feedback' => '1',
				'user'                    => 'james',
				'password'                => 'password'
			}
		}
	end

end
