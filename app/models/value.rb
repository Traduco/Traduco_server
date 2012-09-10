class Value < ActiveRecord::Base
  attr_accessible :isStared, :isTranslated, :value
  
  belongs_to :key
  has_many :translations
end
