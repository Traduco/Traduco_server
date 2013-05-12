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


	project_type_dropdown = $(".project_type_dropdown")
	project_type_dropdown.change ->
		#$this = $(this)
		#ios_element = $("#ios-base-language")
        # Get the selected country Id.
        language_id = $this.val()
        test = $(".project-type-dropdown")

        #if language_id == 0
        #    ios_element.hide(false)
        #else
        #    ios_element.hide(true)


    project_type_dropdown.trigger "change"

	return

