class IOSProcessor
	def find_files (base_path, language_format)
		file_paths = Find.find(base_path)
		found_file_paths = []

		file_paths.each do |file_path|
			found_file_paths << file_path if file_path =~ /\/#{language_format}\.lproj\/(.*).strings$/
		end
		
		found_file_paths
	end

	def find_translation_file (original_file_path, language_format)
		# For iOS, we only need the first two letters of the Language Format.
		format = language_format.split("_")[0]

		# Find the File Name and the Parent Directory Path.
		file_name = File.basename original_file_path
		parent_directory_path = File.expand_path("..", File.dirname(original_file_path))

		# Return the path of the Translation File for the specified Language Format.
		translation_directory_path = File.join parent_directory_path, "#{format}.lproj"
		translation_file_path = File.join translation_directory_path, file_name
	
		return translation_file_path, translation_directory_path
	end

	def parse_file (file_path)
		# Check file existence.
		return if !File.exist? file_path

		lines = []
		result = []

		# Open the file and read its content.
		File.open(file_path, "rb:UTF-16LE") do |f|
			lines = f.readlines
		end

		return if lines.size == 0

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

	def write_file (data, original_file_path, language_format)
		# Find the file name and parent directory of the 
		translation_file_path, translation_directory_path = find_translation_file original_file_path, language_format

		# Make sure that the directory exists.
		Dir.mkpath translation_directory_path if ! Dir.exists? translation_directory_path

		file = File.new(translation_file_path, 'w:UTF-16LE')
		data.each do |hash|
			if ! hash[:comment].empty?
				file.puts("/* #{hash[:comment]} */")
			end
			line = "\"#{hash[:key]}\" = \"#{hash[:value]}\";"
			file.puts line
			file.puts
		end
		file.close

		translation_file_path
	end
end
