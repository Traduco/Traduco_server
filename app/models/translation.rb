class Translation < ActiveRecord::Base
    # Attributes.
    attr_accessible :lock, :lock_date, :user_ids, :language_id, :filter_users
    attr_accessor :user_ids, :language_id

    # Associations.
    belongs_to :language
    belongs_to :project

    has_and_belongs_to_many :users
    has_many :values

    # Triggers.
    before_save :populate_users, :if => :users_changed?
    before_save :populate_language, :if => :language_changed?

    def users_changed?
        self.user_ids
    end

    def language_changed?
        !self.language_id.blank?
    end

    def import_file (source)
        # Retrieve a Loc Process to do the file parsing.
        loc_processor = ProcessorFactory.get_processor self.project.project_type

        # Find the path of our translation file.
        file_path, directory_path = loc_processor.find_translation_file(self.project.get_repository_path + source.file_path, self.language.format)

        # Use the loc processor to retrieve all the keys and values from that file.
        strings = loc_processor.parse_file(file_path)

        # Return if the file wasn't found.
        return if !strings

        keys = source.keys.includes(:default_value)

        # Create the keys for this file
        strings.each do |s|
            key = (keys.select { |k| k.key == s[:key] }).first

            next if !key \
                || (s[:value] == key.default_value.value \
                    && s[:comment] == key.default_value.comment)

            # Create the corresponding value, for this key.
            new_value = Value.new
            new_value.value = s[:value]
            new_value.comment = s[:comment]

            key.values << new_value
            self.values << new_value
        end
    end

    private

    def populate_users
        self.user_ids.delete ""
        self.users = User.find self.user_ids
    end

    def populate_language
        self.language = Language.find self.language_id
    end
end
