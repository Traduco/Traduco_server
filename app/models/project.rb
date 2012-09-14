class Project < ActiveRecord::Base
	attr_accessible :name, :default_language_id, :repository_address, :repository_ssh_key, :repository_type_id, :user_ids
  	attr_accessor :user_ids

    belongs_to :repository_type, :class_name => "RepositoryType"
	belongs_to :default_language, :class_name => "Language"
	has_many :sources
	has_many :translations
	has_and_belongs_to_many :users

	before_save :populate_users, :if => :users_changed?

	def users_changed?
		self.user_ids && self.user_ids.size > 1
	end

	private

	def populate_users
		self.user_ids.delete ""
		self.users = User.find self.user_ids
	end
end
