$ ->
	# Retrieve our controls.
	dropdownLanguages = $("#translation_language_id")
	checkboxFilterUsers = $("#translation_filter_users")

	return if dropdownLanguages.length == 0

	pageUrl = window.location.href

	# Define the ViewModels, and bind the view.
	MainViewModel = (language, filterUsers) ->

		# Properties.
		@users = ko.observableArray()
		@selectedUsers = ko.observableArray()
		@language = ko.observable(language)
		@filterUsers = ko.observable(filterUsers)

		# Computed properties.
		@filteredUsers = ko.computed (=>
			if @filterUsers()
				return @users().filter((u) => -1 != $.inArray(parseInt(@language()), u.languages))
			else
				return @users()
		), this

		# Retrieve the users.
		$.ajax
			url: "users"
			dataType: "json"
			success: (data) =>
				@users(data.users)
				@selectedUsers($.map(data.users.filter((u) -> u.selected), (value) -> value.id))

		return

	# Create the ViewModel and bind it.
	viewModel = new MainViewModel dropdownLanguages.val(), checkboxFilterUsers.is(":checked")
	ko.applyBindings viewModel