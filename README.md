# ETA cacher
ETA (estimated time of arrival) caching service for Wheely.

## Installation
1. Install MongoDB.
2. Install Redis.
3. Do `bundle`.
4. Create DB indices `bundle exec rake db:create_indices`
5. Test it `bundle exec rake test`

## Usage
1. Run `bundle exec ruby app.rb`
2. Create or update cars with `/car?_id=1&lat=55.7516&long=37.6185&available=true`
3. Call ETA with `/eta?lat=55.7000&long=37.6236`
