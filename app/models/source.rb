class Source < ActiveRecord::Base
  attr_accessible :file_path

  belongs_to :project
  has_many :keys
end
