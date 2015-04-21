ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

include Rack::Test::Methods
require_relative '../app'

def app
  Sinatra::Application
end

describe 'app' do
  it 'return status 200 for /' do
    get '/'
    last_response.status.must_equal 200
  end

  it 'should create a Car' do
    get '/car?_id=1&long=55.123&lat=37.123&available=false'
    car = Car.find(1)
    car.wont_be_nil
    car.position.must_equal [55.123, 37.123]
    car.available.must_equal false
  end
end
