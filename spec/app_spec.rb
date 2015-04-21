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
end
