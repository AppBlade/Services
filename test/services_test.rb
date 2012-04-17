require File.expand_path('../helper', __FILE__)

class ServicesTest < Test::Unit::TestCase

	include Rack::Test::Methods

	def app
		Services
	end

	def test_that_it_responds
		get '/'
    assert last_response.ok?
	end

end
