require 'logger'
require 'rubygems'
require 'git-ssh-wrapper'
require 'find'
require_dependency 'extensions/dir_extensions'
require_dependency 'loc_processors/processor_factory'

class Project < ActiveRecord::Base
    # Attributes.
    attr_accessible :name, :default_language_id, :project_type_id, :repository_address, :repository_ssh_key, :repository_type_id, :user_ids, :cloned
    attr_accessor :user_ids

    # Associations.
    belongs_to :default_language, :class_name => "Language"
    belongs_to :project_type, :class_name => "ProjectType"
    belongs_to :repository_type, :class_name => "RepositoryType"

    has_many :sources, :dependent => :destroy
    has_many :translations, :dependent => :destroy
    has_and_belongs_to_many :users

    # Validations.
	validates :name, :presence => true
    
    # Triggers.
    before_save :populate_users, :if => :users_changed?

    def repository_clone
        # Make sure that the directory exists.
        Dir.mkpath self.get_repository_path

        # Clone the repository.
        wrapper = GitSSHWrapper.new(:private_key => self.repository_ssh_key, :log_level => 'ERROR')
        logger.debug `env #{wrapper.cmd_prefix} git clone #{self.repository_address} #{self.get_repository_path} 2>&1`
        
        # Update the project to indicate that it was cloned.
        self.update_attributes(
            :cloned => true
        )
    ensure
        wrapper.unlink if wrapper
    end

    def repository_pull
        # Make sure that our project was cloned a first time.
        if !self.cloned
            self.repository_clone
            return
        end

        # Pull the repository.
		#---------------------
        wrapper = GitSSHWrapper.new(:private_key => self.repository_ssh_key, :log_level => 'ERROR')
        logger.debug `cd #{self.get_repository_path} && env #{wrapper.cmd_prefix} git pull 2>&1`

        # Update the keys and their default_values.
        loc_processor = ProcessorFactory.get_processor self.project_type

        self.sources.each do |source|
            # Parse the file.
            strings = loc_processor.parse_file(get_repository_path + source.file_path)

            # Retrieve the source's keys and corresponding default_values.
            keys = source.keys.includes(:default_value)

            # Add the new keys an update the existing ones.
            strings.each do |string|
                key = (keys.select { |k| k.key == string[:key] }).first

                if !key
                    key = Key.new

                    key.key = string[:key]
                    key_value = Value.new
                else
                    key_value = key.default_value
                end

                key_value.value = string[:value]
                key_value.comment = string[:comment]

                if !key.default_value
                    key.default_value = key_value
                    source.keys << key
                end
            end

            # Remove the keys that were deleted.
            source.keys.each do |key|
                key.destroy if (strings.select { |s| 
                    s[:key] == key.key 
                }).size == 0 
            end

            source.save
        end
    ensure
        wrapper.unlink if wrapper
    end

    def repository_push
        # Pull the repository first to ensure we are up-to-date.
        self.repository_pull

        # Retrieve the Localization Processor for our project type.
        loc_processor = ProcessorFactory.get_processor self.project_type

        file_list = []

        # For each source, write the resource file for each.
        self.sources.each do |source|
            self.translations.each do |translation|
                translation_values = translation.values
                keys = source.keys.includes(:default_value)

                data = []

                # Iterate over the keys to create our data array.
                keys.each do |key|
                    key_value = (translation_values.select { |v| v.key_id == key.id }).first

                    data << {
                        :key => key.key,
                        :value => key_value ? key_value.value : key.default_value.value,
                        :comment => key_value && !key_value.comment.empty? ? key_value.comment : key.default_value.comment
                    }
                end

                # Write the keys to the file.
                file_path = loc_processor.write_file(data, 
                    File.join(get_repository_path, source.file_path), 
                    translation.language.format)

                file_list << get_relative_path(file_path)[1..-1]
            end
        end

        # Add the files to the repository.
        wrapper = GitSSHWrapper.new(:private_key => self.repository_ssh_key, :log_level => 'ERROR')
        logger.debug `cd #{self.get_repository_path} && env #{wrapper.cmd_prefix} git add #{file_list.join(" ")} 2>&1`

        # Commit those added files.
        logger.debug `cd #{self.get_repository_path} && env #{wrapper.cmd_prefix} git commit -am "Traduco Commit of '#{self.name}'." 2>&1`

        # Push the repository.
        logger.debug `cd #{self.get_repository_path} && env #{wrapper.cmd_prefix} git push origin master 2>&1`
    ensure
        wrapper.unlink if wrapper
    end

    def repository_scan
        # Make sure that our project was cloned a first time.
        if !self.cloned
            return []
        end

        # Retrieve the Loc Processor for our Project Type.
        loc_processor = ProcessorFactory.get_processor self.project_type

        # Use the Loc Processor to find the Loc Files in the repository.
        file_list = loc_processor.find_files self.get_repository_path, self.default_language.format
        file_list.map { |file_path| self.get_relative_path(file_path) }
    end

    def import_file (file_path)
        # Retrieve a Loc Process to do the file parsing.
        loc_processor = ProcessorFactory.get_processor self.project_type

        # Use the loc processor to retrieve all the keys and values from that file.
        strings = loc_processor.parse_file(get_repository_path + file_path)
        
		# Create the new Source object for this file.
        new_source = Source.new
        new_source.file_path = file_path

        # Create the keys for this file
        strings.each do |s|
            new_key = Key.new

            new_key.key = s[:key]

            # Create the corresponding value, in default language, for this key.
            new_value = Value.new
            new_value.value = s[:value]
            new_value.comment = s[:comment]

            new_key.default_value = new_value
            new_source.keys << new_key
        end

        self.sources << new_source

        # For each translation in the project, try to import the translation files corresponding to this new file.
        self.translations.each do |translation|
            translation.import_file new_source
        end
    end

    def get_relative_path (path)
        path.slice! get_repository_path
        path
    end

    def get_repository_path
        File.join Rails.root, "repositories", self.id.to_s
    end
        
    def users_changed?
        self.user_ids && self.user_ids.size > 1
    end

    protected

    def populate_users
        self.user_ids.delete ""
        self.users = User.find self.user_ids
    end

end
