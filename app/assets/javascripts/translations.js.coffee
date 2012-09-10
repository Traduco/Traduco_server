$ ->
	# Define the ViewModels, and bind the view.
	StringViewModel = (id, key, base, baseComment, translation, translationComment, isTranslated, isFavorite) ->
		
		# Properties.
		@id = id
		@key = ko.observable(key)
		@base = ko.observable(base)
		@baseComment = ko.observable(baseComment)
		@translation = ko.observable(translation)
		@translationComment = ko.observable(translationComment)
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

		return

	TranslationViewModel = ->
		
		# Properties.
		@files = ko.observableArray()
		@editingFile = ko.observable()

		# Action methods.
		@setEditingFile = (newEditingFile) =>
			@editingFile newEditingFile

		return

	viewModel = new TranslationViewModel

	file1 = new FileViewModel(1, "/klaim/Tada/Loc.strings", 1, 2)
	file1.strings.push new StringViewModel(1, "settings_title", "Settings", "Title of the setting view", "Preferences", "", false, false)
	file1.strings.push new StringViewModel(2, "settings_close_button", "Close", "Button to close the window", "Fermer", "", true, true)
	file1.strings.push new StringViewModel(3, "settings_save_button", "Save", "Button to save the settings", "Enregister", "", false, true)

	viewModel.files.push file1
	viewModel.editingFile file1

	file2 = new FileViewModel(2, "/klaim/HumHum/Loc.strings", 5, 3)

	viewModel.files.push file2

	ko.applyBindings viewModel
