$ ->
	# Define the ViewModel, and bind it.
	testViewModel = ->
		@testvalue = ko.observable("tada")
		return

	ko.applyBindings new testViewModel