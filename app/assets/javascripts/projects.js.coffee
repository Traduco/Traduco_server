$(document).ready ->
	$("#project-tabs a").click (e) ->
		e.preventDefault()
		$(this).tab "show"

		# Send a request to the server to update the session's tab.
		$.ajax({
			url: window.location.href + "/settab",
			type: "PUT",
			data: {
				project_tab: $(this).data("tabname")
			}	
		})

		return

	return