require 'logger'
require 'rubygems'
require 'git-ssh-wrapper'
require 'etc'
require 'find'
require 'pp'
require_dependency 'extensions/dir_extensions'

class Project < ActiveRecord::Base
    attr_accessible :name, :default_language_id, :project_type_id, :repository_address, :repository_ssh_key, :repository_type_id, :user_ids, :cloned
    attr_accessor :user_ids

    belongs_to :default_language, :class_name => "Language"
    belongs_to :project_type, :class_name => "ProjectType"
    belongs_to :repository_type, :class_name => "RepositoryType"

    has_many :sources
    has_many :translations
    has_and_belongs_to_many :users

    before_save :populate_users, :if => :users_changed?

    def repository_pull 
        unless self.cloned
            self.git_clone
            return 
        end
        l = Logger.new('log/debug.log')
        l.level = Logger::DEBUG
        l.debug("in pull"+self.defaultLanguage.name)
    end

    def repository_push

    end

    def repository_clone
        # Make sure that the directory exists.
        repository_path = File.join Rails.root, "repositories", self.id.to_s
        Dir.mkpath repository_path

        # Clone the repository.
        wrapper = GitSSHWrapper.new(:private_key => self.repository_ssh_key, :log_level => 'ERROR')
        @hey = `env #{wrapper.cmd_prefix} git clone #{self.repository_address} #{repository_path} 2>&1`
        logger.debug @hey
        # Update the project to indicate that it was cloned.
        self.cloned = true;
        self.save
    ensure
        wrapper.unlink
    end
	
	def repository_scan
		#self.pull	
		path_to_search = File.join Rails.root, "repositories", self.id.to_s
		logger.debug path_to_search
		default_language_short = self.default_language.format.split('_')[0]
		logger.debug default_language_short
		localizable_files = []
		Find.find(path_to_search) do |path|
			logger.debug path
  			localizable_files.push(path) if path =~ /.*\/#{default_language_short}\.lproj\/Localizable.strings$/
		end
		logger.debug(pp localizable_files)
		return localizable_files
	end

	def load_file_in_database(type)
		deserializer = DeserializerFactory.getDeserializer(type)
		deserializer.deserialize #we need to give him a path/file/etc
	end
        
    def users_changed?
        self.user_ids && self.user_ids.size > 1
    end

    private

    def populate_users
        self.user_ids.delete ""
        self.users = User.find self.user_ids
    end

end
