class Project < ActiveRecord::Base
  attr_accessible :name, :repositoryAddress, :sshKey
  
  belongs_to :repositoryType
  belongs_to :defaultLanguage, :class_name => "Language", :foreign_key => "language_id"
  has_one :repository
  has_many :sources
  has_many :translations
  has_and_belongs_to_many :users
end
