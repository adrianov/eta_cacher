class Car
  include Mongoid::Document
  include Mongoid::Indexable

  field :_id, type: Integer
  field :position, type: Array
  field :available, type: Boolean

  index({position: '2dsphere'})
end
