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

# Custom Click binding to stop event propagation.
ko.bindingHandlers.clickAndStop =
	init: (element, valueAccessor, allBindingsAccessor, viewModel, context) ->
		handler = ko.utils.unwrapObservable valueAccessor()
		newValueAccessor = ->
			(data, event) ->
				handler.call viewModel, data, event
				event.cancelBubble = true
				event.stopPropagation() if event.stopPropagation
				return

		ko.bindingHandlers.click.init element, newValueAccessor, allBindingsAccessor, viewModel, context
		