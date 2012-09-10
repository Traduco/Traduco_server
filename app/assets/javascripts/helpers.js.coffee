# General helpers.
helpers = window.helpers = {}

helpers.toCssPercentage = (ratio) ->
	(ratio.toFixed(2) * 100) + "%"

# Custom DirtyFlag implementation for KnockOutJS viewmodels.
ko.dirtyFlag = (root, isInitiallyDirty) ->
	result = ->
	_initialState = ko.observable ko.toJSON(root)
	_isInitiallyDirty = ko.observable isInitiallyDirty

	result.isDirty = ko.computed ->
		_isInitiallyDirty || _initialState != ko.toJSON root

	result.reset = ->
		_initialState ko.toJSON(root)
		_isInitiallyDirty false
		return

	result

# Extension method to remove all CRLF from a string.
String::singleLine = -> @replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, " "