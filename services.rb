require 'sinatra'
require 'multi_json'
require File.join(File.dirname(__FILE__), 'lib', 'service')

File.open('services.pid', 'w') {|f| f.write Process.pid }

set :port, 9292

get '/' do
  MultiJson.encode Service.subclass_description
end

post '/test' do
  request.body.rewind
  params = MultiJson.decode(request.body.read)
  test_service = Service.module_eval(params['service']).new
  test_service.payload = params
  test_service.settings_test
end

post '/crash_report' do
  process :crash_report
end

post '/new_version' do
  process :new_version
end

post '/feedback' do
  process :feedback
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

# Array#to_sentence from Ruby on Rails
# basicly what's in activesupport/lib/active_support/core_ext/array/conversions.rb:9
class Array
  def to_sentence
    words_connector     = ', '
    two_words_connector = ' and '
    last_word_connector = ', and '

    case length
      when 0
        ""
      when 1
        self[0].to_s
      when 2
        "#{self[0]}#{two_words_connector}#{self[1]}"
      else
        "#{self[0...-1].join(words_connector)}#{last_word_connector}#{self[-1]}"
    end
  end
end
