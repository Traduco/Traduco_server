class RepositoryType < ActiveRecord::Base
  attr_accessible :type, :name
  
  has_many :repositories
end
