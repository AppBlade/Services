class Service::PivotalTracker < Service

	Title = 'Pivotal Tracker'
  Description = 'Use this service to file issues for new crash reports and in-app feedback in Pivotal Tracker.'

  password :api_token
  
  string :project_id

  string :crash_report_story_type, :required => true, :default => 'bug',     :collection => %w(bug feature chore release)
  string :feedback_story_type,     :required => true, :default => 'feature', :collection => %w(bug feature chore release)

	boolean :tag_with_version, :tag_with_platform, :default => true

  def settings_test
    case connection && connection.get("/services/v3/projects/#{settings :project_id}").status
    when 200
      'Success.'
    when 404
      'Could not find project.'
    when 401
      'Invalid API token.'
    else
      return "Settings incorrect."
    end
  rescue => e
    "Settings are incorrect or Pivotal Tracker is not reachable. #{e}"
  end

	def receive_crash_report
    connection.post("/services/v3/projects/#{settings :project_id}/stories", {
      :story => {
        :story_type  => settings(:crash_report_story_type),
        :name        => simple(:message), 
        :description => "A crash has been reported on #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})"
      }
    }).body
	end

  def receive_feedback
    connection.post("/services/v3/projects/#{settings :project_id}/stories", {
      :story => {
        :story_type  => settings(:feedback_story_type),
        :name        => "Feedback from #{simple :user}",
        :description => "#{simple :user} reported in-app feedback for #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})\n\n#{simple :message}"
      }
    }).body
  end

private

  def labels
    labels = []
    labels << simple(:version) if settings :tag_with_version
    labels << simple(:platform) if settings :tag_with_platform
    labels
  end

	def connection
		@connection ||= Faraday.new(:url => 'https://www.pivotaltracker.com') do |builder|
      builder.use     FaradayMiddleware::EncodeJson
      builder.use     FaradayMiddleware::Mashify
      builder.use     FaradayMiddleware::ParseXml
      builder.use     Faraday::Response::RemoveWhitespace
      builder.use     Faraday::Response::RaiseOnAuthenticationFailure
      builder.adapter Faraday.default_adapter
    end.tap do |conn|
      conn.headers = {
        :accept => 'application/xml',
        :user_agent => 'AppBlade/Services/1.0 (Easy, like your mom)',
        'X-TrackerToken' => settings(:api_token)
      }
    end
	end

end


