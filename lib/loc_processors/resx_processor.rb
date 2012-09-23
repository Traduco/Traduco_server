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
		nodes = document.find('/root/data')
		to_return = Array.new
		nodes.each do |node|
			hash = {}
			hash[:value] = node.find_first("value").content
			hash[:key] = node["name"]
			hash[:comment] = ""
			hash[:comment] = node.find_first("comment").content if node.find_first("comment")
			to_return.push(hash)
		end
		to_return
	end

	def write_file (data, original_file_path, language_format)
	end	
end
