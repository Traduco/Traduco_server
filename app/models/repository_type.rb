class RepositoryType < ActiveRecord::Base
    # Attributes.
    attr_accessible :key, :name

    # Associations.
    has_many :projects
end
