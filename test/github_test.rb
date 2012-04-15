require File.expand_path('../helper', __FILE__)

class GithubTest < Service::TestCase

	SettingsPayload = {
		'api_token'        => 'xxxxxxxxxxxxxx',
		'username'         => 'jamesdaniels',
		'project'          => 'AppBlade/Services',
		'tag_for_crash'    => 'Crash',
		'tag_with_version' => true
	}

	def setup
		@service ||= Service::Github.new
	end

	def teardown
	end

# Setup complete, start testing

	def test_crash_reports
		service.payload = crash_report_payload
	end

private

	def service
		@service
	end

end

