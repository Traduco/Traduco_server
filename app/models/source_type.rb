class SourceType < ActiveRecord::Base
  attr_accessible :name, :type
  
  has_many :sources
end
