class Source < ActiveRecord::Base
    # Attributes.
    attr_accessible :file_path

    # Associations.
    belongs_to :project
    has_many :keys, :dependent => :destroy
end
