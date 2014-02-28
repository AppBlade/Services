require 'uri'

class Service::Callback < Service

  Title = 'Callback'
  Description = 'Use this service to make an HTTP post against your own server.'

  string :url, :secret, required: true

  def settings_test
    connection.post path, payload_to_submit('settings_test')
    'Success.'
  rescue RuntimeError => e
    e.message
  rescue Faraday::Error => e
    e.message
  end

  def receive_new_version
    connection.post path, payload_to_submit('new_version')
    'Success.'
  end

  def receive_crash_report
    connection.post path, payload_to_submit('crash_report')
    'Success.'
  end

  def receive_feedback
    connection.post path, payload_to_submit('feedback')
    'Success.'
  end

private

  def path
    URI(settings(:url)).path
  end

  def payload_to_submit(trigger)
    payload_to_submit = payload.reject do |k,v|
      k == 'settings'
    end
    payload_to_submit[:secret] = settings(:secret)
    payload_to_submit[:trigger] = trigger
    payload_to_submit
  end

  def host
    settings(:url) =~ /^(.+)#{URI(settings(:url)).path}$/ && $1
  end

  def connection
    @connection ||= Faraday.new(:url => host) do |builder|
      builder.use     FaradayMiddleware::EncodeJson
      builder.use     FaradayMiddleware::Mashify
      builder.use     Faraday::Response::RemoveWhitespace
      builder.adapter Faraday.default_adapter
    end.tap do |conn|
      conn.headers = {
        user_agent: 'AppBlade/Services/1.0 (Easy, like your mom)'
      }
    end
  end

end
