class SourcesController < ApplicationController
	
	before_filter :check_auth
	before_filter :get_data
	before_filter :get_source, :only => [:show, :update]

	def get_data
		@project = Project.find params[:project_id]
		@translation = Translation.find params[:translation_id]
	end

	def get_source
		@source = Source.find params[:id]

		# Retrieve all the values for this translation and this source.
		@values = Value \
			.joins(:key) \
			.where("keys.source_id = #{@source.id} and values.translation_id = #{@translation.id}")
	end

	def index
		render :json => {
			:sources => @project.sources.map { |source| { 
				:id => source.id,
				:file_path => source.file_path
		}}}
	end

	def show
		strings = []
		keys = @source.keys.includes(:default_value)

		keys.each do |key|
			key_value = (@values.select { |v| v.key_id == key.id }).first

			new_string = {
				:id => key.id,
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
			:id => @source.id,
			:file_path => @source.file_path,
			:strings => strings
		}
	end

	def update
		strings = params[:strings]
		strings.values.each do |updated_string|
			# Find the corresponding value, or create it.
			key_value = (@values.select { |v| v.key_id == updated_string[:id] }).first
			if !key_value
				key = @source.keys.find(updated_string[:id])
				key_value = @translation.values.build

				key.values << key_value
				@translation.values << key_value
			end

			# Update the fields of the value with what we received.
			key_value.value = updated_string[:translated_value]
			key_value.comment = updated_string[:translated_comment]
			key_value.is_stared = updated_string[:is_stared]
			key_value.is_translated = updated_string[:is_translated]

			key_value.save
		end

		render :json => {
			:status => "success"
		}
	end
end
