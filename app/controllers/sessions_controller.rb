class SessionsController < ApplicationController
	before_filter :layout_setup

	def layout_setup
		@tab = :login
	end

	def create
		user = User.authenticate(params[:email], params[:password])
		if user
			session[:user_id] = user.id
			redirect_to root_url, :notice => {
				:title => "Logged in!"
			}
		else
			render "new"
		end
	end

	def destroy
		session[:user_id] = nil
		redirect_to root_url, :notice => {
			:title => "Logged out!"
		}
	end

end
