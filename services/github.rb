class Service::Github < Service

	Title = 'GitHub'
	Description = 'Use this service to file GitHub Issues for new crash reports, feedback, and unprovisioned devices.'

	string :username, :api_token, :project, :required => true
	string :tag_for_crash, :default => 'Crash'
	boolean :tag_with_version, :tag_with_platform

	def settings_correct?
		connection.get("/api/v2/json/repos/show/#{settings :project}").status == 200
	end

	def receive_crash_report
		if settings_correct?
			response = connection.post("/api/v2/json/issues/open/#{settings :project}", {
				:title => simple(:message), 
				:body => "A crash has been reported on #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})"
			})
			if response.status == 201
				number = MultiJson.decode(response.body)['issue']['number']
				connection.post "/api/v2/json/issues/label/add/#{settings :project}/#{simple :version}/#{number}" if settings :tag_with_version
				connection.post "/api/v2/json/issues/label/add/#{settings :project}/#{simple :platform}/#{number}" if settings :tag_with_platform
				connection.post "/api/v2/json/issues/label/add/#{settings :project}/#{settings :tag_for_crash}/#{number}" unless settings(:tag_for_crash).blank?
				"Success."
			else
				"Failed to create issue, error #{response.status}"
			end
		else
			"Settings are incorrect."
		end
	end

private

	def connection
		@connection ||= Faraday.new(:url => 'https://github.com').tap do |conn|
			conn.basic_auth "#{settings :username}/token", settings(:api_token)
		end
	end

end
