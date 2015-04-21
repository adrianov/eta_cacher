require 'haversine'

class Eta
  def self.eta(dst)
    car = Car.near_sphere(position: dst).first
    external(car.position, dst)
  end

  # Imitating external ETA service querying
  def self.external(src, dst)
    Haversine.distance(src, dst).to_kilometers * 1.5
  end
end
