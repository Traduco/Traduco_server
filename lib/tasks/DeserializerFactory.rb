class DeserializerFactory
	def self.getDeserializer (type)
		case type
		when 0 # iOS
			return IOSDeserializer.new
		when 1 # Windows phone 7 
			return WPDeserializer.new
		end
	end
end
