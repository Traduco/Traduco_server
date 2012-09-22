$ ->
	return if $(".table-strings").length == 0

	pageUrl = window.location.href

	# Define the ViewModels, and bind the view.
	StringViewModel = (id, key, originalValue, originalComment, translatedValue, translatedComment, isTranslated, isFavorite) ->
		
		# Properties.
		@id = id
		@key = ko.observable(key)
		@originalValue = ko.observable(originalValue)
		@originalComment = ko.observable(originalComment)
		@translatedValue = ko.observable(translatedValue)
		@translatedComment = ko.observable(translatedComment)
		@isTranslated = ko.observable(isTranslated)
		@isFavorite = ko.observable(isFavorite)
		@dirtyFlag = ko.dirtyFlag(this)

		# Action methods.
		@toggleTranslated = ->
			@isTranslated !@isTranslated()
			viewModel.saveModel()
			return

		@toggleFavorite = ->
			@isFavorite !@isFavorite()
			viewModel.saveModel()
			return

		return

	FileViewModel = (id, path, stringCount, translatedStringCount) ->

		# Properties.
		@id = id
		@path = path
		@strings = ko.observableArray()
		@editingString = ko.observable()
		@isSaving = ko.observable(false)

		_stringCount = stringCount
		_translatedStringCount = translatedStringCount

		@stringCount = ko.computed (->
			return @strings().length if @strings().length > 0
			_stringCount
		), this

		@translatedStringCount = ko.computed (->
			return ko.utils.arrayFilter(@strings(), (aString) -> aString.isTranslated()).length if @strings().length > 0
			_translatedStringCount
		), this

		@translationCompletionPercentage = ko.computed (->
			helpers.toCssPercentage @translatedStringCount() / @stringCount()), this

		# Action methods.
		@setEditingString = (newEditingString) =>
			@editingString newEditingString
			return

		@loadString = =>
			$.ajax(pageUrl + "/sources/" + @id).done((data) =>
				@strings($.map(data.strings, (value, index) ->
					new StringViewModel(
						value.id,
						value.key,
						value.original_value,
						value.original_comment,
						value.translated_value,
						value.translated_comment,
						value.is_translated,
						value.is_stared
					)
				))
			)
			return

		return

	TranslationViewModel = ->
		
		# Properties.
		@files = ko.observableArray()
		@editingFile = ko.observable(null)

		# Computed properties.
		@isSaving = ko.computed (=>
			result = false

			$.each(@files(), (index, value) ->
				result = true if value.isSaving()
			)

			result
		), this

		# Action methods.
		@setEditingFile = (newEditingFile) =>
			@editingFile newEditingFile

			# If the strings for this file weren't loaded yet, load them.
			newEditingFile.loadString() if newEditingFile.strings().length == 0
			return

		@saveModel = =>
			# For each file, push to the server the updated strings.
			$.each(@files(), (index, value) ->
				# Stop here if the file was already being saved.
				return if value.isSaving()

				# Find the updated strings.
				filesToUpdate = value.strings().filter((s) -> s.dirtyFlag.isDirty())
				return if filesToUpdate.length == 0

				# Set the file in a saving state.
				value.isSaving(true)

				# Send them to the server.
				$.ajax {
					url: pageUrl + "/sources/" + value.id,
					type: "PUT",
					data: {
						strings: $.map(filesToUpdate, (value) ->
							value.dirtyFlag.reset()
							return {
								id: value.id,
								translated_value: value.translatedValue(),
								translated_comment: value.translatedComment(),
								is_stared: value.isFavorite(),
								is_translated: value.isTranslated()
							}
						)
					}
					complete: ->
						value.isSaving(false)
						return
				}
				return
			)
			return

		# Retrieve a list of files.
		$.ajax(pageUrl + "/sources").done((data) =>
			@files($.map(data.sources, (value, index) =>
				new_file = new FileViewModel(value.id, value.file_path, 1, 1)
				
				# If there is no file currently being edited, set this one as the current file.
				@setEditingFile(new_file) if @editingFile() == null
				new_file
			))
		)

		return

	# Create the ViewModel and bind it.
	viewModel = new TranslationViewModel
	ko.applyBindings viewModel
