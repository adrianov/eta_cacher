ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

include Rack::Test::Methods
require_relative '../app'

def app
  Sinatra::Application
end

describe 'app' do
  before do
    Car.delete_all
    Car.create_indexes
  end

  it 'return status 200 for /' do
    get '/'
    last_response.status.must_equal 200
  end

  it 'should create and update a car' do
    get '/car?_id=1&long=55.123&lat=37.123&available=false'
    car = Car.find(1)
    car.wont_be_nil
    car.position.must_equal [55.123, 37.123]
    car.available.must_equal false

    get '/car?_id=1&long=55.7000&lat=37.6236&available=true'
    car = Car.find(1)
    car.wont_be_nil
    car.position.must_equal [55.7000, 37.6236]
    car.available.must_equal true
  end

  it 'should calculate ETA' do
    # from Kremlin
    get '/car?_id=1&long=55.7527&lat=37.6171&available=true'

    # to Kremlin
    get '/eta?long=55.7527&lat=37.6171'
    last_response.body.to_f.must_equal 0

    # to Wheely office
    get '/eta?long=55.7000&lat=37.6236'
    last_response.body.to_f.must_be_close_to 5.8740 * 1.5, 0.001
  end
end
