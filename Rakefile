require './app.rb'

namespace :db do
  task :create_indices, :environment do
    Mongoid.load!('./config/mongoid.yml', settings.environment)
    Car.create_indexes
  end
end
