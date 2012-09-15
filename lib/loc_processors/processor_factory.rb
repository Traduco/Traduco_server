require_dependency 'loc_processors/ios_processor'
require_dependency 'loc_processors/resx_processor'

class ProcessorFactory
	def self.get_processor (project_type)
		case project_type.key
		when 2
			return ResxProcessor.new
		else
			return IOSProcessor.new
		end
	end
end