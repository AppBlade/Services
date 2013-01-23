class Service::Github < Service

	Title = 'GitHub'
	Description = 'Use this service to file GitHub Issues for new crash reports, feedback, and unprovisioned devices.'

	string  :project, :required => true
	string  :tag_for_crash, :default => 'Crash'
	boolean :tag_with_version, :tag_with_platform

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
    labels = []
    labels << simple(:version) if settings :tag_with_version
    labels << simple(:platform) if settings :tag_with_platform
    labels << settings(:tag_for_crash) unless settings(:tag_for_crash).blank?
    connection.post("/repos/#{settings :project}/issues", {
      :title => simple(:message), 
      :body => "A crash has been reported on #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})",
      :labels => labels
    })
	end

private

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
