class RepositoryType < ActiveRecord::Base
  attr_accessible :key, :name
  
  has_many :projects
end
