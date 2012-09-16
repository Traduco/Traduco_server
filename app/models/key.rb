class Key < ActiveRecord::Base
  attr_accessible :key
  
  belongs_to :source
  belongs_to :default_value, :class_name => "Value"
  has_many :values
end
