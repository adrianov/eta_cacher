require 'haversine'

# Estimated time of arrival
class Eta
  def initialize(redis)
    @redis = redis
  end

  # 1. Look at exact square
  # 2. Look at 9 near squares for src and dst (9 * 9 = 81 pipelined looks)
  # 3. Ask external service
  def eta(dst)
    car = Car.near_sphere(position: dst).first
    cache_look_exact(car.position, dst) || cache_look_near(car.position, dst) || external(car.position, dst)
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
    # 'eta:55.72:37.27:55.30:37.00' =>
    #   [
    #     "{ src: [55.723, 37.273], dst: [55.301, 37.004], eta: 15.32 }",
    #     "{ src: [55.721, 37.2743], dst: [55.303, 37.002], eta: 16.31 }"
    #   ]
    def redis_save(src, dst, eta)
      @redis.rpush redis_key(src, dst), {src: src, dst: dst, eta: eta}.to_json
    end

    # Look at exact src & dst squares
    def cache_look_exact(src, dst)
      #p 'exact'
      parse_redis_result src, dst, @redis.lrange(redis_key(src, dst), 0, -1)
    end

    # Look at adjacent squares
    def cache_look_near(src, dst)
      #p 'near'

      s = src.map { |e| e.round(2) }
      d = dst.map { |e| e.round(2) }

      # Pipeline for speedup
      res = @redis.pipelined do
        # 3 ^ 4 = 81 looks
        [s[0], s[0] - 0.01, s[0] + 0.01].each do |s0|
          [s[1], s[1] - 0.01, s[1] + 0.01].each do |s1|
            [d[0], d[0] - 0.01, d[0] + 0.01].each do |d0|
              [d[1], d[1] - 0.01, d[1] + 0.01].each do |d1|
                @redis.lrange(redis_key([s0, s1], [d0, d1]), 0, -1)
              end
            end
          end
        end
      end

      res.flatten!
      parse_redis_result src, dst, res
    end

    def parse_redis_result(src, dst, res)
      return nil if res.empty?
      res.map! { |e| JSON.parse(e, symbolize_names: true) }
      select_nearest(src, dst, res)[:eta]
    end

    # E. g.: 'eta:55.72:37.27:55.30:37.00'
    def redis_key(src, dst)
      'eta:' + (src + dst).map { |a| sprintf('%.2f', a.round(2)) }.join(':')
    end

    # Selecting best result from cached square
    # Sort by actual geometric distance
    def select_nearest(src, dst, src_dst_ary)
      src_dst_ary.sort_by { |a| Haversine.distance(src, a[:src]).to_m + Haversine.distance(dst, a[:dst]).to_m }.first
    end
end
