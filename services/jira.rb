class Service::Jira < Service

	Title = 'JIRA'
  Description = 'Use this service to file issues for new crash reports and in-app feedback in Atlassian\'s JIRA.'

  string :server_url, :username
  
  password :password
  
  string :project_key

  string :crash_issue_type, :required => true, :default => 'Bug'
  string :feedback_issue_type, :required => true, :default => 'Improvement'

	boolean :tag_with_version, :tag_with_platform, :default => true

  # TODO: 
  # * validate the crash_issue_type and feedback_issue_type
  # * allow them to set the priority & validate
  # * allow them to set notification options & validate
  # * allow them to set an assignee & validate
  def settings_test
    case connection && connection.get("/rest/api/2/project/#{settings :project_key}").status
    when 200
      'Success.'
    when 404
      'Unknown project key.'
    when 401
      'Invalid API token.'
    else
      "Settings incorrect."
    end
  rescue
    "Settings are incorrect or your JIRA instance is not reachable."
  end

	def receive_crash_report
    connection.post("/rest/api/2/issue", {
      :fields => {
        :project     => { :key => settings(:project_key) },
        :issuetype   => { :name => settings(:crash_issue_type) },
        :summary     => simple(:message), 
        :description => "A crash has been reported on #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})",
        :labels      => labels + ['Crash']
      }
    }).body
	end

  def receive_feedback
    connection.post("/rest/api/2/issue", {
      :fields => {
        :project     => { :key => settings(:project_key) },
        :issuetype   => { :name => settings(:feedback_issue_type) },
        :summary     => "Feedback from #{simple :user}",
        :description => "#{simple :user} reported in-app feedback for #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})\n\n#{simple :message}",
        :labels      => labels + ['Feedback']
      }
    }).body
  end

private

  def labels
    labels = []
    labels << simple(:version).gsub(' ', '') if settings :tag_with_version
    labels << simple(:platform) if settings :tag_with_platform
    labels.reject(&:blank?)
  end

	def connection
		@connection ||= Faraday.new(:url => settings(:server_url)) do |builder|
      builder.use     FaradayMiddleware::EncodeJson
      builder.use     FaradayMiddleware::Mashify
      builder.use     FaradayMiddleware::ParseJson
      builder.use     Faraday::Response::RemoveWhitespace
      builder.use     Faraday::Response::RaiseOnAuthenticationFailure
      builder.adapter Faraday.default_adapter
    end.tap do |conn|
      conn.headers = {
        :accept => 'application/json',
        :user_agent => 'AppBlade/Services/1.0 (Easy, like your mom)'
      }
      conn.basic_auth settings(:username), settings(:password)
    end
	end

end

