require_dependency 'loc_processors/ios_processor'
require_dependency 'loc_processors/android_processor'
require_dependency 'loc_processors/resx_processor'

class ProcessorFactory
	def self.get_processor (project_type)
		case project_type.key
		when 1
			return AndroidProcessor.new
		when 2
			return ResxProcessor.new
		else
			return IOSProcessor.new
		end
	end
end