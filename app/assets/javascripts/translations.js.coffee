$ ->
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
			return

		@toggleFavorite = ->
			@isFavorite !@isFavorite()
			return

		return

	FileViewModel = (id, path, stringCount, translatedStringCount) ->

		# Properties.
		@id = id
		@path = path
		@strings = ko.observableArray()
		@editingString = ko.observable()

		_stringCount = stringCount
		_translatedStringCount = translatedStringCount

		@stringCount = ko.computed (->
			return @strings().length if @strings().length > 0
			_stringCount), this

		@translatedStringCount = ko.computed (->
			return ko.utils.arrayFilter(@strings(), (aString) -> aString.isTranslated()).length if @strings().length > 0
			_translatedStringCount), this

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

		# Action methods.
		@setEditingFile = (newEditingFile) =>
			@editingFile newEditingFile
			newEditingFile.loadString() if newEditingFile.strings().length == 0
			return

		# Retrieve a list of files.
		$.ajax(pageUrl + "/sources").done((data) =>
			@files($.map(data.sources, (value, index) =>
				new_file = new FileViewModel(value.id, value.file_path, 1, 1)
				@setEditingFile(new_file) if @editingFile() == null
				new_file
			))
		)

		return

	viewModel = new TranslationViewModel
	ko.applyBindings viewModel
