require File.expand_path('../helper', __FILE__)

class GithubTest < Service::TestCase

	def setup
		@service ||= Service::Github.new
	end

	def teardown
	end

# Setup complete, start testing

	def test_listener_registration
		assert Service.crash_report_listeners.include? Service::Github
	end

	def test_crash_reports
		service.payload = crash_report_payload
	end

private

	def service
		@service
	end

end

