class Key < ActiveRecord::Base
    # Attributes.
    attr_accessible :key

    # Associations.
    belongs_to :source
    belongs_to :default_value, :class_name => "Value"
    has_many :values, :dependent => :destroy
end
