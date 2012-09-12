class Translation < ActiveRecord::Base
  attr_accessible :lock, :lock_date 
  belongs_to :value
  belongs_to :language
  belongs_to :project
  
  has_and_belongs_to_many :users
end
