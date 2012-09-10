class Repository < ActiveRecord::Base
  attr_accessible :address, :name, :sshKey
  
  belongs_to :repositoryType
  belongs_to :project
end
