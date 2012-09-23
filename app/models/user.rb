require "bcrypt"

class User < ActiveRecord::Base
    # Attributes.
    attr_accessible :email, :first_name, :last_name, :language_ids, :is_site_admin, :new_password, :new_password_confirmation
    attr_accessor :language_ids, :new_password, :new_password_confirmation

    # Associations.
    has_and_belongs_to_many :languages
    has_and_belongs_to_many :translations
    has_and_belongs_to_many :projects
	
    # Validations.
	validates :new_password, :confirmation => :true
	validates :email, :presence => true, :format => { :with => /[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}/ }
	validates :first_name, :presence => true
	validates :last_name, :presence => true	

    # Triggers.
    before_save :hash_new_password, :if => :password_changed?
    before_save :populate_languages, :if => :languages_changed?

    def full_name
        self.first_name + " " + self.last_name
    end

    def self.authenticate (email, password)
        user = find_by_email email
        if user && user.password == BCrypt::Engine.hash_secret(password, user.password_salt)
            user
        else
            nil
        end
    end

    def validate_password? (password)
        hashed_pass = BCrypt::Password.create(password)
        hashed_pass == self.password
    end

    # By default the form_helpers will set new_password to "",
    # we don't want to go saving this as a password
    def password_changed?
        !self.new_password.blank?
    end

    def languages_changed?
        self.language_ids
    end

    private

    # This is where the real work is done, store the BCrypt has in the
    # database
    def hash_new_password
        self.password_salt = BCrypt::Engine.generate_salt
        self.password = BCrypt::Engine.hash_secret(self.new_password, self.password_salt)
    end

    def populate_languages
        self.language_ids.delete ""
        self.languages = Language.find self.language_ids
    end
end
