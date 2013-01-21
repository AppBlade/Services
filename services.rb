require 'sinatra'
require 'multi_json'
require File.join(File.dirname(__FILE__), 'lib', 'service')

set :port, 9292

get '/' do
  MultiJson.encode Service.subclass_description
end

post '/crash_report' do
  process :crash_report
end

post '/new_version' do
  process :new_version
end

def process(service)
  request.body.rewind
  response = MultiJson.decode(request.body.read)
  MultiJson.encode(Service.send("#{service}_listeners").inject({}) do |collection, listener_class|
    if response['settings'].keys.include? listener_class.to_s
      listener_class.new.tap do |listener|
        listener.payload = response
        collection[listener_class.to_s] = listener.send "receive_#{service}"
      end
    end
    collection
  end)
end
