class Car
  include Mongoid::Document
  field :_id, type: Integer
  field :position, type: Array
  field :available, type: Boolean
end
