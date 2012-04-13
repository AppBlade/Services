require 'tinder'

class Service::Campfire < Service

  string :subdomain, :room_name, :api_token, :required => true
	string :sound, :default => 'rimshot', :collection => %w(secret trombone crickets rimshot vuvuzela tmyk live drama yeah greatjob pushit nyan tada ohmy bueller ohyeah)

	def settings_correct?
		begin
			!!room
		rescue
			false
		end
	end

  def receive_crash_report
		room.speak "[#{simple(:project)}/#{simple(:version)}] #{simple(:message)}: #{url}"
		room.play settings(:sound) unless settings(:sound).blank?
  end

private

	def connection
		@connection ||= Tinder::Campfire.new settings(:subdomain), :token => settings(:api_token)
	end

	def room
		@room ||= connection.find_room_by_name settings(:room_name)
	end
	
end
