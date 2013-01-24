class Service::Github < Service

	Title = 'GitHub'
	Description = 'Use this service to file GitHub Issues for new crash reports and in-app feedback.'

	string  :project, :required => true
	boolean :tag_with_version, :tag_with_platform, :default => true

  oauth :github

  def settings_test
    case connection && connection.get("/repos/#{settings :project}").status
    when 200
      'Success.'
    when 404
      'Unknown repo.'
    when 401
      'Invalid API token.'
    else
      "Settings incorrect."
    end
  rescue
    "Settings are incorrect or GitHub is not reachable."
  end

	def receive_crash_report
    connection.post("/repos/#{settings :project}/issues", {
      :title => simple(:message), 
      :body => "A crash has been reported on #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})",
      :labels => labels + ['Crash report']
    }).body
	end

  def receive_feedback
    connection.post("/repos/#{settings :project}/issues", {
      :title => "Feedback from #{simple :user}",
      :body => "#{simple :user} reported in-app feedback for #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})\n\n#{simple :message}",
      :labels => labels + ['Feedback']
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
		@connection ||= Faraday.new(:url => 'https://api.github.com') do |builder|
      builder.use     FaradayMiddleware::EncodeJson
      builder.use     FaradayMiddleware::Mashify
      builder.use     FaradayMiddleware::ParseJson
      builder.use     Faraday::Response::RemoveWhitespace
      builder.use     Faraday::Response::RaiseOnAuthenticationFailure
      builder.adapter Faraday.default_adapter
    end.tap do |conn|
      conn.headers = {
        :accept => "application/vnd.github.v3+json\napplication/json",
        :user_agent => 'AppBlade/Services/1.0 (Easy, like your mom)',
        :authorization => "token #{settings(:access_token)}"
      }
    end
	end

end
