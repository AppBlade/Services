require File.expand_path('../helper', __FILE__)

class GithubTest < Service::TestCase

	def setup
		@service ||= Service::Github.new
	end

	def teardown
	end

# Setup complete, start testing

	def test_crash_reports
		service.payload = crash_report_payload
		service.receive_crash_report
	end

private

	def service
		@service
	end

	def crash_report_payload
    {
			'settings' => {
				'api_token'        => 'xxxxxxxxxxxxxx',
				'username'         => 'jamesdaniels',
				'project'          => 'AppBlade/Services',
				'tag_for_crash'    => 'Crash',
				'tag_with_version' => true
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

