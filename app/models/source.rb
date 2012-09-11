class Source < ActiveRecord::Base
  attr_accessible :filePath
  
  belongs_to :project
  belongs_to :sourceType
  
  has_many :keys
end
