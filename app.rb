require 'sinatra'
require 'haversine'

get '/' do
  'hi'
end

get '/car' do
  'car'
end

get '/eta/:lat/:long' do
  'eta'
end
