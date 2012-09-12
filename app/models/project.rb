class Project < ActiveRecord::Base
	attr_accessible :name, :user_ids
	attr_accessor :user_ids
  
	belongs_to :defaultLanguage, :class_name => "Language", :foreign_key => "language_id"
	has_one :repository
	has_many :sources
	has_many :translations
	has_and_belongs_to_many :users

	before_save :populate_users, :if => :users_changed?

	def users_changed?
		!self.user_ids.blank?
	end

	private

	def populate_users
		self.user_ids.delete ""
		self.users = User.find self.user_ids
	end

end
