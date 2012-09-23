class Translation < ActiveRecord::Base
	attr_accessible :lock, :lock_date, :user_ids, :language_id, :filter_users
	attr_accessor :user_ids, :language_id

	belongs_to :language
	belongs_to :project

	has_and_belongs_to_many :users
	has_many :values
	
	validates :language_id, :presence => true, :length => { :minimum => 1 }	

	before_save :populate_users, :if => :users_changed?
	before_save :populate_language, :if => :language_changed?

	def users_changed?
		self.user_ids
	end

	def language_changed?
		!self.language_id.blank?
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
