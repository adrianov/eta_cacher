# ETA cacher
ETA (estimated time of arrival) caching service for Wheely.

## Algorithm
1. Calculate dst and src GeoHashes with chosen decimal precision (5).
2. Look Redis for desired GeoHashes. Return associated ETA value if exists, end.
3. Ask external service for ETA. Return it and save it to Redis.

## Installation
1. Install MongoDB.
2. Install Redis.
3. Do `bundle`.
4. Create DB indices `bundle exec rake db:create_indexes`
5. Test it `bundle exec rake test`

## Usage
1. Run `bundle exec ruby app.rb`
2. Create or update cars with `/car?_id=1&lat=55.7516&long=37.6185&available=true`
3. Call ETA with `/eta?lat=55.7000&long=37.6236`
