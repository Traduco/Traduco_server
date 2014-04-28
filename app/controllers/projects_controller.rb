require_dependency 'helpers/hashing_helpers'
require_dependency 'loc_processors/processor_factory'

class ProjectsController < ApplicationController
	include HashingHelpers

	#before_filter :check_auth
	before_filter :check_site_admin, :only => [:new, :create]
	before_filter :layout_setup
	before_filter :get_project, :only => [:pull, :push, :add_files, :set_tab, :show, :new, :edit, :update, :destroy]
	before_filter :get_additional_data, :only => [:pull, :push, :new, :edit, :update, :destroy]
	before_filter :check_project_admin, :only => [:pull, :push, :add_files, :edit, :update, :destroy]
	before_filter :get_translations, :only => [:show, :set_tab]
	before_filter :check_translator, :only => [:show, :set_tab]

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
	end

	def get_additional_data
		@users = User.all.map { |user| [user.full_name, user.id] }	
		@project_types = ProjectType.all.map { |project_type| [project_type.name, project_type.id] }
		@languages = Language.all.map { |language| [language.format + " - " + language.name, language.id] }
		@repository_types = RepositoryType.all.map { |repository_type| [repository_type.name, repository_type.id] }
	end

	def get_translations
		# if is_project_admin 
			# @translations = @project.translations
		# else
		# 	@translations = @current_user.translations.find_all { |translation| translation.project_id == @project.id }
		# end
		@translations = []
	end

	def pull
		@project.delay.repository_pull
		redirect_to @project
	end

	def push
		if !@project.cloned
			redirect_to @project, :notice => {
				:type => :error,
		        :title => "Error!",
		        :message => "The repository was not cloned yet!"
			}
		end

		@project.delay.repository_push
		redirect_to @project
	end

	def add_files
		# Prepare the data for the view and the rest of the process.
	 	@new_files = @project.repository_scan

	 	# Remove from new_files those which were already added.
	 	@new_files = @new_files - @project.sources.map { |source| source.file_path }

	 	# If the form was submitted, add the files to the DB and redirect.
		files_request = params[:files]
		if files_request
			@new_files.each do |file|
				# Check if this file must be parsed and included in the database.
				if files_request.keys.include? md5(file)
					@project.import_file file
				end
			end

			# Redirect.
			redirect_to @project, :notice => {
				:title => "Files Added!",
				:message => "The new files were added successfully."
			}
		end
	end

	def set_tab
		if params[:project_tab] == "files"
			tab = :files
		else
			tab = :translations
		end

		session[project_tab_session_key] = tab

		render :json => {}
	end

	def show
		# Tab.
		@tab = session[project_tab_session_key] ? session[project_tab_session_key] : :translations
		
		@project[:total_strings] = get_total_keys(@project)
		
		@project.sources.each do |source|
			source[:total_strings] = source.keys.count * @project.translations.count
			source[:translated_strings] = source.keys.joins(:values).where("values.is_translated = true").count
		end
		
		@translations.each do |translation|
			translation[:translated_strings] = translation.values.where(:is_translated => true).count
		end

		render :json => { 
			:project =>  {
				:id => @project.id,
				:name => @project.name,
				#:translatedStrings => @project.translated_strings,
				:totalStrings => @project.total_strings
			}
		}

	end

	def index
		#if is_site_admin
			@projects = Project.find(:all, :include => :users)
		#else
			# Retrieve all the projects for our user (as project admin and translator)
		#	@projects = @current_user.projects + @current_user.translations.map { |translation| translation.project }	
		#	@projects.uniq! { |project| project.id }
		#end
		
		@projects.each do |project|
			project[:translated_strings] = project.translations.joins(:values).where("values.is_translated = true").count
			project[:total_strings] = get_total_keys(project) * project.translations.count
		end
		render :json => { 
			:data => @projects.map { |project| {
				:id => project.id,
				:name => project.name,
				:translatedStrings => project.translated_strings,
				:totalStrings => project.total_strings
			}},
			:total => @projects.count
		}
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

	protected

	def project_tab_session_key
		"project_tab_#{@project.id}"
	end
	
	def get_total_keys (project)
		return project.sources.joins(:keys).count
	end
end
