class User < ActiveRecord::Base
  attr_accessible :email, :firstName, :lastName, :password
  
  has_and_belongs_to_many :languages
  has_and_belongs_to_many :translations
  has_and_belongs_to_many :projects
end
