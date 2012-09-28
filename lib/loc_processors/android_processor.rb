require 'xml'

class AndroidProcessor
	def find_files (base_path, language_format)
		file_paths = Find.find(base_path)
		found_file_paths = []

		file_paths.each do |file_path|
			found_file_paths << file_path if (file_path =~ /.*\/values\/.*\.xml$/)
		end
	
		found_file_paths
	end

	def find_translation_file (original_file_path, language_format)
		# in Android, each language should have a folder at the same level
		#-----------------------------------------------------------------
		format = language_format.split("_")[0]

		file_name = File.basename original_file_path
		parent_directory_path = File.expand_path("..", File.dirname(original_file_path))
		
		# now let's return the two values
		#--------------------------------
		translation_directory_path = File.join parent_directory_path, "values-#{format}"
		translation_file_path = File.join translation_directory_path, file_name

		return translation_file_path, translation_directory_path 	
	end

	def parse_file (file_path)
		return if !File.exists? file_path

		result = []
		parser = XML::Parser.file(file_path)
		document = parser.parse
		
		# Parsing the normal form of localized strings
		#---------------------------------------------
		nodes = document.find("/resources/string")
		nodes.each do |node|
			result << {
				:value		=> node.content,
				:key		=> node["name"],
				:comment	=> ""
			}
		end
		
		# Parsing the second form of localized strings.
		# Apparently outdated and we should use "string-array"
		#-----------------------------------------------------
		nodes_array = document.find("/resources/array")
		nodes_array.each do |node_array|
			elements = []
			node_array.each_element do |element|
				elements << element.content
			end
			values = elements.join(", ")
			result << {
				:value		=> "[#{values}]",
				:key		=> node_array["name"],
				:comment	=> ""
			}
		end 

		#return all values
		#-----------------
		result	
	end

	def write_file (data, original_file_path, language_format)
		# we need first to create the new file_path with the language format
		#-------------------------------------------------------------------
		translation_file_path, translation_directory_path = find_translation_file original_file_path, language_format

		# we now need to load in memory the original file
		#------------------------------------------------
		XML.indent_tree_output = true
		parser = XML::Parser.file(original_file_path, :options => XML::Parser::Options::NOBLANKS)
		document = parser.parse

		# we can now modify the values based on the received data
		#--------------------------------------------------------
		data.each do |hash|
			if hash[:value] =~ /\[(.+)\]/
				nodes = document.find("/resources/array[@name = '#{hash[:key]}']")
				if nodes
					node_to_change = nodes[0]
					node_to_change.children.each { |element| element.remove! }
					$1.split(", ").each do |item|
						sub_node = XML::Node.new("item")
						sub_node.content = item
						node_to_change << sub_node
					end
				end
			else 
				nodes = document.find("/resources/string[@name = '#{hash[:key]}']")
				if nodes
					node = nodes[0]
					node.content = hash[:value]	
				end
			end	
		end
	
		# Make sur the directory exists
		#------------------------------
		Dir.mkdir translation_directory_path if ! Dir.exists? translation_directory_path
  
		# we now have to save this document to a different file
		#------------------------------------------------------
		document.save(translation_file_path, :indent => true, :encoding => XML::Encoding::UTF_8)

		translation_file_path
	
	end
end
