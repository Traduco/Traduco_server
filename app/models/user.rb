require "bcrypt"

class User < ActiveRecord::Base
    attr_accessible :email, :first_name, :last_name, :language_ids, :new_password, :new_password_confirm
    attr_accessor :language_ids, :new_password, :new_password_confirm

    has_and_belongs_to_many :languages
    has_and_belongs_to_many :translations
    has_and_belongs_to_many :projects

    before_save :hash_new_password, :if => :password_changed?
    before_save :populate_languages, :if => :languages_changed?

    def full_name
        self.first_name + " " + self.last_name
    end

    # By default the form_helpers will set new_password to "",
    # we don't want to go saving this as a password
    def password_changed?
        !@new_password.blank?
    end

    def languages_changed?
        self.language_ids && self.language_ids.size > 1
    end

    private

    # This is where the real work is done, store the BCrypt has in the
    # database
    def hash_new_password
        @password = BCrypt::Password.create(@new_password)
    end

    def populate_languages
        self.language_ids.delete ""
        logger.debug "HEYHEYHEY"
        logger.debug self.language_ids
        self.languages = Language.find self.language_ids
    end
end
