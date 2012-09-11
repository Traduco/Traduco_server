class Translation < ActiveRecord::Base
  attr_accessible :lock :lockDate 
  belongs_to :value
  belongs_to :language
  belongs_to :project
  
  has_and_belongs_to_many :users
end
