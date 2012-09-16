class Value < ActiveRecord::Base
  attr_accessible :is_stared, :is_translated, :value, :comment
  
  belongs_to :key
  belongs_to :translation
end
