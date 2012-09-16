require_dependency 'helpers/hashing_helpers'
require_dependency 'loc_processors/processor_factory'

class ProjectsController < ApplicationController
	include HashingHelpers

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
	end

	def add_files
		# Prepare the data for the view and the rest of the process.
		@project = Project.find params[:id], :include => [
		 	:sources
	 	]
	 	@new_files = @project.repository_scan

	 	# Remove from new_files those which were already added.
	 	@new_files = @new_files - @project.sources.map { |source| source.file_path }

	 	# If the form was submitted, add the files to the DB and redirect.
		files_request = params[:files]
		if files_request
			@new_files.each do |file|
				# Check if this file must be parsed and included in the database.
				if files_request.keys.include? md5(file)

					# Retrieve a Loc Process to do the file parsing.
					loc_processor = ProcessorFactory.get_processor @project.project_type

					# Use the loc processor to retrieve all the keys and values from that file.
					strings = loc_processor.parse_file(file)

					# Create the new Source object for this file.
					new_source = @project.sources.build
					new_source.file_path = file

					# Create the keys for this file
					strings.each do |s|
						new_key = new_source.keys.build

						new_key.key = s[:key]

						# Create the corresponding value, in default language, for this key.
						new_value = new_key.values.build
						new_value.value = s[:value]
						new_value.comment = s[:comment]

						new_key.default_value = new_value
						new_source.keys << new_key
					end

					@project.sources << new_source
				end
			end

			# Redirect.
			redirect_to @project, :notice => {
				:title => "Files Added!",
				:message => "The new files were added successfully."
			}
		end
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
