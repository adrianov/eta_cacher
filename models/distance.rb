# ETA distance cache
class Distance
  include Mongoid::Document
  field :src, type: Array
  field :dst, type: Array
  field :eta, type: Float
end
