# Post to the provided URL with the specified parameters.
App.util = {}

App.util.post = (path, parameters) ->
  form = $('<form></form>').attr(
    "method": "post"
    "action": path
  )

  for own key, value of parameters
    field = $('<input/>').attr(
      "type": "hidden"
      "name": key
      "value": value
    )
    form.append field

  $(document.body).append form
  form.submit()
