class Key < ActiveRecord::Base
  attr_accessible :comment, :key
  
  belongs_to :source
  has_many :values
  
end
