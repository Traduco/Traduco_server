class TranslationsController < ApplicationController	
	before_filter :layout_setup
	before_filter :get_data, :only => [:show, :users, :new, :edit, :update, :destroy]
	before_filter :get_additional_data, :only => [:new, :edit]

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
			@translation = @project.translations.build
		end
	end

	def get_additional_data
		@users = User.all.map { |user| [user.full_name, user.id] }	
		@languages = Language.all.map { |language| [language.format + " - " + language.name, language.id] }
	end

	def users
		users = User.all
		translation_user_ids = @translation.users.map { |user| user.id }

		render :json => { 
					:users => users.map { |user| {
						:id => user.id,
						:name => user.full_name,
						:languages => user.languages.map { |lang| lang.id },
						:selected => translation_user_ids.include?(user.id)
				}}}
	end

	def create		
		@project = Project.find params[:project_id]
		@translation = Translation.new(params[:translation])

		@project.translations.push @translation

		@users = User.all.map { |user| [user.full_name, user.id] }	
		@languages = Language.all.map { |language| [language.format + " - " + language.name, language.id] }

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
end
