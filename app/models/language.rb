class Language < ActiveRecord::Base
    # Attributes.
    attr_accessible :format, :name
  
    # Associations.
    has_many :projects
    has_many :translations
    has_and_belongs_to_many :users
end
