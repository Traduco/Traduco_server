class Value < ActiveRecord::Base
    # Attributes.
    attr_accessible :is_stared, :is_translated, :value, :comment

    # Associations.
    belongs_to :key
    belongs_to :translation
end
