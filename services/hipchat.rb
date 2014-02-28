class Service::Hipchat < Service

  Title = 'HipChat'
  Description = 'Use this service to broadcast updates, crash reports, and feedback to Atlassian HipChat.'

  string :room, required: true
  password :token, required: true
  string :crash_report_color, :feedback_color, :new_version_color, collection: %w(yellow red green purple gray random), default: 'yellow'
  boolean :post_on_crash_report, :post_on_feedback, :post_on_new_version, default: true
  boolean :notify_on_crash_report, default: true
  boolean :notify_on_feedback, :notify_on_new_version, default: false

  def settings_test
    'Success.'
  end

  def receive_crash_report
    if settings(:post_on_crash_report) == '1'
      speak "#{subject} #{simple :message}: #{url}", settings(:crash_report_color), settings(:notify_on_crash_report)
    end
    "Success."
  end

  def receive_new_version
    if settings(:post_on_new_version) == '1'
      speak "#{subject} was just uploaded to AppBlade by #{simple :user}: #{url}", settings(:new_version_color), settings(:notify_on_new_version)
    end
    "Success."
  end

  def receive_feedback
    if settings(:post_on_feedback) == '1'
      speak "#{subject} just had in-app feedback submitted to AppBlade by #{simple :user}: #{url}", settings(:feedback_color), settings(:notify_on_feedback)
    end
    "Success."
  end

private

  def subject
    "[#{simple :project}/#{simple :platform}/#{simple :version}]"
  end

  def connection
    @connection ||= Faraday.new(:url => 'https://api.hipchat.com') do |builder|
      builder.use     Faraday::Request::UrlEncoded
      builder.use     FaradayMiddleware::Mashify
      builder.use     FaradayMiddleware::ParseJson
      builder.use     Faraday::Response::RemoveWhitespace
      builder.adapter Faraday.default_adapter
    end.tap do |conn|
      conn.request :url_encoded
      conn.headers = {
        accept:     'application/json',
        user_agent: 'AppBlade/Services/1.0 (Easy, like your mom)'
      }
    end
  end

  def speak(text, color, notify)
    connection.post('/v1/rooms/message', {
      auth_token:     settings(:token),
      room_id:        settings(:room),
      from:           'AppBlade.com',
      message:        text,
      message_format: 'text',
      notify:         notify,
      color:          color
    })
  end

end
