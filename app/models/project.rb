class Project < ActiveRecord::Base
	attr_accessible :name, :repository_address, :ssh_key, :user_ids, :default_language_id
  	attr_accessor :user_ids, :default_language_id

    belongs_to :repositoryType
	belongs_to :default_language, :class_name => "Language", :foreign_key => "language_id"
	has_one :repository
	has_many :sources
	has_many :translations
	has_and_belongs_to_many :users

	before_save :populate_users, :if => :users_changed?
	before_save :populate_default_language, :if => :default_language_changed?

	def users_changed?
		self.user_ids && self.user_ids.size > 1
	end

	def default_language_changed?
		!self.default_language_id.blank?
	end

	private

	def populate_users
		self.user_ids.delete ""
		self.users = User.find self.user_ids
	end

	def populate_default_language
		self.default_language = Language.find self.default_language_id
	end
end
