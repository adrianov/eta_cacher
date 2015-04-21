require 'sinatra'
require 'sinatra/param'
require 'mongoid'
require './models/car'
require './models/distance'
require './models/eta'

if development?
  require 'sinatra/reloader'
  require 'better_errors'
end

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

Mongoid.load!('./config/mongoid.yml', settings.environment)

get '/' do
  status 200
end

# Sets car parameters
get '/car' do
  param :_id, Integer, required: true
  param :lat, Float, min: -180, max: 180
  param :long, Float, min: -180, max: 180
  param :available, Sinatra::Param::Boolean, default: true

  car = Car.find_or_create_by(_id: params['_id'])
  car.update(
      position: [params[:long], params[:lat]],
      available: params[:available]
  )
  car.to_json
end

# Returns ETA for [:long, :lat]
get '/eta' do
  param :lat, Float, min: -180, max: 180
  param :long, Float, min: -180, max: 180
  Eta::eta([params[:long], params[:lat]]).to_s
end
