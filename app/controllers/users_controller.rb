class UsersController < ApplicationController
	
	before_filter :check_auth
	before_filter :check_site_admin, :only => [:index, :new, :create, :destroy]
	before_filter :layout_setup
	before_filter :get_data, :only => [:edit, :update, :destroy]
	before_filter :get_languages, :only => [:new, :edit, :update]

	def layout_setup
		@tab = :users
	end

	def get_data
		if @current_user.is_site_admin
			@user = User.find params[:id], :include => :languages	
		else
			@user = @current_user
		end
	end

	def get_languages
		@languages = Language.all.map { |language| [language.name, language.id] }	
	end

	def index
		@users = User.all
	end

	def new
		@user = User.new
	end

	def edit
		@user.language_ids = @user.languages.map { |language| language.id }
	end

	def create
		@user = User.new(params[:user])
		if @user.save
			redirect_to users_path, :notice => {
				:type => :success,
				:title => "Success!",
				:message => "User " + @user.full_name + " was created."
			}
		else
			render :action => "new"
		end
	end

	def update
		@user.attributes = params[:user]

		if @user.save
			redirect_to @current_user.is_site_admin ? users_path : root_url, 
				:notice => {
					:type => :success,
					:title => "Saved!"
			}
		else
			render :action => "edit"
		end
	end

	def destroy
		@user.destroy

		redirect_to users_path, :notice => {
			:type => :success,
			:title => "Well done!",
			:message => "The user \"" + @user.full_name + "\" was deleted successfully."
		}
	end
end