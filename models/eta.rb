require 'haversine'
require 'geohash'

# Estimated time of arrival
class Eta
  # GeoHash decimal precision
  PRECISION = 5

  def initialize(redis)
    @redis = redis
  end

  # 1. Look cache
  # 2. Ask external service
  def eta(dst)
    cars = Car.near_sphere(position: dst).where(available: true).limit(3)

    return nil if cars.count == 0

    etas = []
    cars.each do |car|
      etas << (cache_look(car.position, dst) || external(car.position, dst))
    end

    etas.reduce(&:+) / etas.length
  end

  private
    # Imitating external ETA service querying
    # Caching result after querying
    def external(src, dst)
      #p 'external'
      eta = Haversine.distance(src, dst).to_kilometers * 1.5
      redis_save(src, dst, eta)
      eta
    end

    # Saving to redis as:
    # 'geohash1:geohash2' => 15.32
    def redis_save(src, dst, eta)
      @redis.set redis_key(src, dst), eta
    end

    # Look at exact src & dst squares
    def cache_look(src, dst)
      #p 'cache'
      res = @redis.get redis_key(src, dst)
      res.to_f if res
    end

    # E. g.: 'geohash1:geohash2'
    def redis_key(src, dst)
      "#{GeoHash.encode(src[1], src[0], PRECISION)}:#{GeoHash.encode(dst[1], dst[0], PRECISION)}"
    end
end
