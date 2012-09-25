require 'xml'

class ResxProcessor
    def find_files (base_path, language_format)
		file_paths = Find.find(base_path)
        found_file_paths = []
        
        file_paths.each do |file_path|
            found_file_paths << file_path if (file_path =~ /.*\.resx/ \
            	&& file_path !~ /.*\.[a-zA-z\-]{2,5}\.resx/)
        end

        found_file_paths
    end

    def find_translation_file (original_file_path, language_format)
    	language_format.sub!("_", "-")
		base_file_name = File.basename original_file_path, ".resx"

		translation_directory_path = File.dirname original_file_path
		translation_file_path = File.join translation_directory_path, "#{base_file_name}.#{language_format}.resx"

		return translation_file_path, translation_directory_path
	end

  	def parse_file (file_path)
  		return if !File.exists? file_path

        parser = XML::Parser.file(file_path)
        document = parser.parse # gives a parsed document
        nodes = document.find("/root/data")

        result = []

        nodes.each do |node|    
            result << {
                :value      => node.find_first("value").content,
                :key        => node["name"],
                :comment    => node.find_first("comment") ? node.find_first("comment").content : ""
            }
        end

        result
    end

	def write_file (data, original_file_path, language_format)
		# we need first to create the new file_path with the language format
		#-------------------------------------------------------------------
		translation_file_path, translation_directory_path = find_translation_file original_file_path, language_format

		# we now need to load in memory the original file
		#------------------------------------------------
		parser = XML::Parser.file(original_file_path)
		document = parser.parse

		# we can now modify the values based on the received data
		#--------------------------------------------------------
		data.each do |hash|
			nodes = document.find("/root/data[@name = '#{hash[:key]}']")
			if nodes
				node = nodes[0]
				node.find_first("value").content = hash[:value]
				if ! hash[:comment].empty?
					if node.find_first("comment")
						node.find_first("comment").content = hash[:comment]
					else
						comment = XML::Node.new("comment")
						comment.content = hash[:comment]
						node << comment
					end
				end
			end	
		end
 
		# we now have to save this document to a different file
		#------------------------------------------------------
		document.save(translation_file_path, :indent => true, :encoding => XML::Encoding::UTF_8)

		translation_file_path
	end	
end
