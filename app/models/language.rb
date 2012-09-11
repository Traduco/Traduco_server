class Language < ActiveRecord::Base
  attr_accessible :format, :name
  
  has_many :projects
  has_many :translations
  has_and_belongs_to_many :users
end
