class Service::Github < Service

  string :username, :api_token, :project, :required => true
	string :tag, :default => 'Crash'
	boolean :tag_with_version

	def settings_correct?
		issues.status == 200
	end

  def receive_crash_report
		number = MultiJson.decode(connection.post("/api/v2/json/issues/open/#{settings :project}", {
			:title => simple(:message), 
			:body => "A crash has been reported on #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})"
		}).body)['issue']['number']
		connection.post "/api/v2/json/issues/label/add/#{settings :project}/#{simple :version}/#{number}" if settings :tag_with_version
		connection.post "/api/v2/json/issues/label/add/#{settings :project}/#{settings :tag}/#{number}" unless settings(:tag).blank?
  end

private

	def connection
		@connection ||= Faraday.new(:url => 'https://github.com').tap do |conn|
			conn.basic_auth "#{settings :username}/token", settings(:api_token)
		end
	end

	def issues
		connection.get "/api/v2/json/issues/list/#{settings :project}/open"
	end

end

