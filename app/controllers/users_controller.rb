class UsersController < ApplicationController
	before_filter :layout_setup

	def layout_setup
		@tab = :users
	end

	def index
		@users = User.all
	end

	def show
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(params[:user])
		if @user.save
			redirect_to(@user)
		else
			render :action => "new"
		end
	end

end