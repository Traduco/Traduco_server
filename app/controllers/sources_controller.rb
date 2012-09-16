class SourcesController < ApplicationController
	before_filter :get_data

	def get_data
		@project = Project.find params[:project_id]
		@translation = Translation.find params[:translation_id]
	end

	def index
		render :json => {
			:sources => @project.sources.map { |source| { 
				:id => source.id,
				:file_path => source.file_path
		}}}
	end

	def show
		source = Source.find params[:id]
		translation_values = @translation.values

		strings = []

		source.keys.each do |key|
			key_value = (translation_values.select { |v| v.key_id == key.id }).first

			new_string = {
				:key => key.key,
				:original_value => key.default_value.value,
				:original_comment => key.default_value.comment ? key.default_value.comment : "",
				:translated_value => key_value ? key_value.value : "",
				:translated_comment => key_value ? key_value.comment : "",
				:is_stared => key_value ? key_value.is_stared : false,
				:is_translated => key_value ? key_value.is_translated : false
			}

			strings << new_string
		end

		render :json => {
			:id => source.id,
			:file_path => source.file_path,
			:strings => strings
		}
	end
end
