require 'logger'
require 'rubygems'
require 'git'
require 'etc'

class Project < ActiveRecord::Base
  attr_accessible :name, :repositoryAddress, :sshKey, :cloned
  
  belongs_to :repositoryType
  belongs_to :defaultLanguage, :class_name => "Language", :foreign_key => "language_id"
  has_one :repository
  has_many :sources
  has_many :translations
  has_and_belongs_to_many :users

	def git_pull
		unless self.cloned
			self.git_clone
			return
		end
		l = Logger.new('log/debug.log')
		l.level = Logger::DEBUG
		l.debug("in pull"+self.defaultLanguage.name)
	end

	def git_push

	end

	def git_clone
		g = Git.clone('git@github.com:quentez/Klaim-iOS', 'klaim_repo', {:depth => 1, :path => Etc.getpwuid.dir}) 
		#g = Git.clone('git@github.com:quentez/Klaim-iOS', 'klaim_repo', {:depth => 1})		
		self.cloned = true;
		self.save
	end
end
