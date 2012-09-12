class ProjectsController < ApplicationController
	before_filter :layout_setup

	def layout_setup
		@tab = :projects
	end

	def index
		@projects = Project.find(:all, :include => :users)
	end

	def show
		@project = Project.find(params[:id])
	end

	def new
		@project = Project.new
		@users = User.all.map { |user| [ user.fullName, user.id ] }
	end

	def create
		@project = Project.new(params[:project])
		@users = User.all

		if @project.save
			redirect_to(@project)
		else
			render :action => "new"
		end
	end

	def destroy
		project = Project.find(params[:id])
		project.destroy

		redirect_to projects_path, :notice => {
			:type => :success,
			:title => "Well done!",
			:message => "The project \"" + project.name + "\" was deleted successfully."
		}
	end
end
