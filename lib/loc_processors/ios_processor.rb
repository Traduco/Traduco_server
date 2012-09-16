class IOSProcessor
	def find_files (file_paths, language_format)
		found_file_paths = []

		file_paths.each do |file_path|
			found_file_paths << file_path if file_path =~ /\/#{language_format}\.lproj\/(.*).strings$/
		end
		found_file_paths
	end

	def parse_file (file_path)
		lines = []
		result = []

		# Open the file and read its content.
		# TODO: A solution must be found for this encoding problem!
		File.open(file_path, "rb:UTF-16LE") do |f|
			lines = f.readlines
		end

		if lines.size == 0
			return
		end

		# Get the file encoding.
		encoding = lines[0].encoding

		lines.each_index do |line_index|
			line = lines[line_index]

			# Convert the line to UTF-8
			line.encode! "UTF-8"

			if line =~ /"(.*)" = "(.*)";/
				key = $1
				value = $2
				comment = ""

				# Retrieve the previous line, in UTF-8, and check if it's a comment.
				previous_line = lines[line_index - 1].encode "UTF-8"

				if previous_line =~ /\/\*\s*(.*)[\s*]\*\//
					comment = $1
				end

				# Add this newfound key to the result.
				result << {
					:key => key,
					:value => value,
					:comment => comment
				}
			end
		end

		result
	end	

	def write_file (data, language_format)

	end
end