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

	def write_file (data, original_file_path, language_format)
		
		# For iOS, we only need the first two letters of the language format
		#-------------------------------------------------------------------
		format = language_format.split('_')[0]
		# we need to know if we are writing Localizable.strings or any other file
		#------------------------------------------------------------------------
		file_name = File.basename(original_file_path, ".strings")
			
		# finding where to put the new file
		#----------------------------------
		original_directory = File.dirname(original_file_path)
		parent_path = File.join(original_directory, '..')
		all_translation_directories = File.expand_path(parent_path)
		directory_to_create_file =  File.join(all_translation_directories, "#{format}.lproj")

		# do we need to create that directory ?
		#--------------------------------------
		if ! Dir.exist?(directory_to_create_file)
			Dir.mkdir(directory_to_create_file)
		end

		file_to_create = File.join(directory_to_create_file, "#{file_name}.strings")
		file = File.new(file_to_create, 'w:UTF-16LE')
		data.each do |hash|
			if ! hash[:comment].empty?
				file.puts("/* #{hash[:comment]} */")
			end
			line = "\"#{hash[:key]}\" = \"#{hash[:value]}\";"
			file.puts(line)
			file.puts()
		end
		file.close
		
		# fetching the data and writing it in the file
		#---------------------------------------------

		# what's the format for that ? what's data ?
		
	end
end
