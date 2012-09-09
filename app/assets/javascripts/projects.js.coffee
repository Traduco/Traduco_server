$(document).ready ->
	$("#project-tabs a").click (e) ->
		e.preventDefault()
		$(this).tab "show"
