$ ->
	# Define a new binding to handle realtime textchange.
	ko.bindingHandlers.rtValue =
		init: (element, valueAccessor) ->
			jElement = $(element)
			jElement.bind "textchange", ->
				observable = valueAccessor()
				observable $(this).val()
				return
			return
		update: (element, valueAccessor) ->
			observable = valueAccessor()
			$(element).val observable()
			return

	# Define the ViewModel, and bind it.
	testViewModel = ->
		@testvalue = ko.observable("tada")
		return

	ko.applyBindings new testViewModel