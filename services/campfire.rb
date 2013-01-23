require 'tinder'

class Service::Campfire < Service

	Title = 'Campfire'
	Description = 'Use this service to broadcast updates, crash reports, unprovisioned devices, and feedback to 37Signals Campfire.'

	string :subdomain, :room_name, :required => true
	string :sound, :default => 'rimshot', :collection => %w(secret trombone crickets rimshot vuvuzela tmyk live drama yeah greatjob pushit nyan tada ohmy bueller ohyeah)

  oauth :thirty_seven_signals

  def settings_test
    return "Sub-domain is required" if settings(:subdomain).blank?
    return "Room name is required"  if settings(:room_name).blank?
    !!room && 'Success.' || 'Invalid room name.'
  rescue Tinder::AuthenticationFailed => e
    "Invalid sub-domain or API token."
  rescue => e
    'Invalid settings or Campfire is unreachable.'
  end

	def receive_crash_report
		room.speak "#{subject} #{simple :message}: #{url}"
    room.play settings(:sound) unless settings(:sound).blank?
		"Success."
	end

	def receive_new_version
		room.speak "#{subject} was just uploaded to AppBlade by #{simple :user}: #{url}"
	end

private

	def connection
		@connection ||= Tinder::Campfire.new settings(:subdomain), :token => settings(:access_token), :oauth => true
	end

	def subject
		"[#{simple :project}/#{simple :platform}/#{simple :version}]"
	end

	def room
		@room ||= connection.find_room_by_name settings(:room_name)
	end
	
end
