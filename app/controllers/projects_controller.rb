class ProjectsController < ApplicationController
	before_filter :layout_setup
	before_filter :get_project, :only => [:new, :edit, :update, :destroy]

	def layout_setup
		@tab = :projects
	end

	def get_project
		if params.has_key? :id
			@project = Project.find params[:id], :include => [
					:users,
					:default_language
				]
		else
			@project = Project.new
		end

	
		@users = User.all.map { |user| [user.full_name, user.id] }	
		@project_types = ProjectType.all.map { |project_type| [project_type.name, project_type.id] }
		@languages = Language.all.map { |language| [language.format + " - " + language.name, language.id] }
		@repository_types = RepositoryType.all.map { |repository_type| [repository_type.name, repository_type.id] }
	end

	def index
		@projects = Project.find(:all, :include => :users)
	end

	def show
		@project = Project.find params[:id], :include => [
		 	:users,
		 	:translations
	 	]

	 	@project.repository_clone
	end

	def new
	end

	def edit
		@project.user_ids = @project.users.map { |user| user.id }
		@project.default_language_id = @project.default_language.id
	end

	def create
		@project = Project.new(params[:project])
		@users = User.all.map { |user| [ user.full_name, user.id ] }

		if @project.save
			redirect_to(@project)
		else
			render :action => "new"
		end
	end

	def update
		@project.attributes = params[:project]

		if @project.save
			redirect_to @project, :notice => {
				:type => :success,
				:title => "Saved!"				
			}
		else
			render :action => "edit"
		end
	end

	def destroy
		@project.destroy

		redirect_to projects_path, :notice => {
			:type => :success,
			:title => "Well done!",
			:message => "The project \"" + @project.name + "\" was deleted successfully."
		}
	end
end
