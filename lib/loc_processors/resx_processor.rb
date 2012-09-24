require 'xml'

class ResxProcessor
	def find_files (file_paths, language_format)
		found_file_paths = []
		file_paths.each do |file_path|
			if (file_path =~ /.*\.resx/ && file_path !~ /.*\.[a-zA-z\-]{2,5}\.resx/)
				found_file_paths << file_path
			end	
		end
		found_file_paths
	end

	def parse_file (file_path)
		parser = XML::Parser.file(file_path)
		document = parser.parse # gives a parsed document
		nodes = document.find("/root/data")
		to_return = []
		nodes.each do |node|	
			to_return << {
				:value		=> node.find_first("value").content,
				:key 		=> node["name"],
				:comment	=> node.find_first("comment") ? node.find_first("comment").content : ""
			}
		end
		to_return
	end

	def write_file (data, original_file_path, language_format)
		# we need first to create the new file_path with the language format
		#-------------------------------------------------------------------
		directory_path = File.dirname(original_file_path)
		file_name = File.basename(original_file_path, ".resx")
		file_to_create = File.join(directory_path, "#{file_name}.#{language_format}.resx")

		# we now need to load in memory the original file
		#------------------------------------------------
		parser = XML::Parser.file(file_path)
		document = parser.parse

		# we can now modify the values based on the received data
		#--------------------------------------------------------
		data.each do |hash|
		
		end
 
		# we now have to save this document to a different file
		#------------------------------------------------------
		document.save(file_to_create, :indent => true)
	end	
end
