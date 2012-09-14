class Source < ActiveRecord::Base
  attr_accessible :filePath
  
  belongs_to :project
  belongs_to :source_type
  
  has_many :keys
end
