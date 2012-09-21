require_dependency 'helpers/hashing_helpers'

module ProjectsHelper
	include HashingHelpers

	def addfiles_project_path (project)
		project_path(project) + "/addfiles"
	end

	def action_project_path (project, action)
		project_path(project) + "/" + action
	end

end
