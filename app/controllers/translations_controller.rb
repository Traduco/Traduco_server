class TranslationsController < ApplicationController

	before_filter :check_auth
	before_filter :layout_setup
	before_filter :get_data, :only => [:show, :users, :new, :create, :edit, :update, :destroy]
	before_filter :get_additional_data, :only => [:new, :edit, :create, :update]
	before_filter :check_project_admin, :only => [:users, :new, :edit, :create, :update, :destroy]
	before_filter :check_translator

	def layout_setup
		@tab = :projects
	end

	def get_data
		@project = Project.find params[:project_id]

		if params.has_key? :id
			@translation = Translation.find params[:id], :include => [
				:users,
				:language
			]
			@translation.user_ids = @translation.users.map { |user| user.id }
		else
			@translation = Translation.new
		end

		# Computed values.	
		@is_project_admin = (@project && (@project.users.map { |user| user.id }).include?(@current_user.id)) || @current_user.is_site_admin
		@is_translator = (@translation && (@translation.users.map { |user| user.id }).include?(@current_user.id)) || @is_project_admin
	end

	def check_project_admin
		redirect_to_project if !@is_project_admin
	end

	def check_translator
		redirect_to_project if !@is_translator
	end

	def get_additional_data
		@users = User.all.map { |user| [user.full_name, user.id] }	
		@languages = Language.all.map { |language| [language.format + " - " + language.name, language.id] }
	end

	def users
		users = User.all
		translation_user_ids = @translation.users.map { |user| user.id } if @translation

		render :json => { 
					:users => users.map { |user| {
						:id => user.id,
						:name => user.full_name,
						:languages => user.languages.map { |lang| lang.id },
						:selected => @translation && translation_user_ids.include?(user.id)
				}}}
	end

	def create
		@translation = Translation.new(params[:translation])
		@project.translations << @translation

		if @project.save
			redirect_to project_translation_path(@project, @translation) 
		else
			render :action => "new"
		end
	end

	def update
		@translation.attributes = params[:translation]

		if @translation.save
			redirect_to [@project, @translation], :notice => {
				:title => "Saved!"				
			}
		else
			render :action => "edit"
		end
	end

	def destroy
		@translation.destroy

		redirect_to project_path(@project), :notice => {
			:type => :success,
			:title => "Well done!",
			:message => "The translation for language \"" + @translation.language.name + "\" was deleted successfully."
		}
	end

	protected

	def redirect_to_project
		redirect_to @project ? @project : root_url, 
			:notice => {
				:type => :error,
				:title => "Forbidden!",
				:message => "You can't access this area."
		}
	end
end
