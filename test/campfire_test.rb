require File.expand_path('../helper', __FILE__)

class CampfireTest < Service::TestCase

	SettingsPayload = {
		'api_token' => 'aaaaaaaa',
		'subdomain' => 'appblade',
		'room_name' => 'AppBlade',
		'sound'     => 'secret'
	}

	def setup
		@service ||= Service::Campfire.new
	end

	def teardown
	end

# Setup complete, start testing

	def test_listener_registration
		assert Service.crash_report_listeners.include? Service::Campfire
		assert Service.new_version_listeners.include? Service::Campfire
	end

	def test_crash_reports
		service.payload = crash_report_payload
	end

	def test_new_version
		service.payload = new_version_payload
	end

private

	def service
		@service
	end

end
