class Value < ActiveRecord::Base
  attr_accessible :is_stared, :is_translated, :value
  
  belongs_to :key
  has_many :translations
end
