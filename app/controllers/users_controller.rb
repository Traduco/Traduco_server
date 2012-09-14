class UsersController < ApplicationController
	before_filter :layout_setup
	before_filter :get_user, :only => [:edit, :update, :destroy]

	def layout_setup
		@tab = :users
	end

	def get_user
		@user = User.find(params[:id])		
	end

	def index
		@users = User.all
	end

	def new
		@user = User.new
	end

	def edit
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
			redirect_to users_path, :notice => {
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