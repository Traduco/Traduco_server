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
	end

	def write_file (data, original_file_path, language_format)
	end	
end
