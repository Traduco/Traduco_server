class IOSProcessor
	def find_files (file_paths, language_format)
		found_file_paths = []

		file_paths.each do |file_path|
			found_file_paths << file_path if file_path =~ /\/#{language_format}\.lproj\/(.*).strings$/
		end
		found_file_paths
	end
end