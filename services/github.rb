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
      :title => "#{title_format :notes}",
      :body => "#{simple :user} reported in-app feedback for #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})\n\n#{body_format :notes} \n\n#{simple :device}\n#{simple :device_id}",
      :labels => labels + ['Feedback']
    }).body
  end


def body_format(attr)
	#TODO: image handling, likely formatted somewhere in notes or settings
	payload['simple'][attr.to_s]
end

def title_format(attr)
	to_ret = payload['simple'][attr.to_s] 
	#simple cutoff logic and formatting
	return to_ret[0,77]+'...' unless to_ret.length < 80
	to_ret 
end


private

  def labels
    labels = []
    labels << simple(:version) if settings(:tag_with_version) == '1'
    labels << simple(:platform) if settings(:tag_with_platform) == '1'
    labels.reject(&:blank?)
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
