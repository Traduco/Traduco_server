class TranslationsController < ApplicationController	
	before_filter :layout_setup

	def layout_setup
		@tab = :projects
	end

	def show
		
	end
end
