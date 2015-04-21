ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

include Rack::Test::Methods
require_relative '../app'

def app
  Sinatra::Application
end

$redis = Redis.new(url: 'redis://localhost:6379/15')

describe 'app' do
  before do
    Car.delete_all
    Car.create_indexes
    $redis.flushdb
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

describe 'ETA cache' do
  before do
    Car.delete_all
    Car.create_indexes
    $redis.flushdb
    Eta.send(:public, *Eta.private_instance_methods)
    @eta = Eta.new($redis)
  end

  it 'should select nearest cached value' do
    src_dst_ary = [
        {src: [1, 2], dst: [3, 4], eta: 2},
        {src: [1, 3], dst: [3, 4], eta: 1},
    ]
    @eta.select_nearest([1, 2], [3, 4], src_dst_ary).must_equal({src: [1, 2], dst: [3, 4], eta: 2})
  end

  it 'should store and read using Redis cache' do
    get '/car?_id=1&long=55.7527&lat=37.6171&available=true'
    get '/eta?long=55.7000&lat=37.6236'
    res = last_response.body.to_f
    @eta.cache_look_exact([55.7527, 37.6171], [55.7000, 37.6236]).must_equal res
    @eta.cache_look_near([55.7527, 37.6171], [55.7000, 37.6236]).must_equal res
    @eta.cache_look_near([55.7527 + 0.01, 37.6171], [55.7000, 37.6236 + 0.01]).must_equal res

    get '/eta?long=55.7012&lat=37.6311'
    last_response.body.to_f.must_equal res
  end
end
