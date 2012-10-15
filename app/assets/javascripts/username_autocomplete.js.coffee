class App.UsernameAutocomplete

  init: (field) ->
    @field = $(field)

    shift = false
    #facebook, twitter: when autocomplete sequence is broken?
    #twitter: how they search by all users?
    @field.keydown (event) ->
      shift = true if event.shiftKey
      @doAutocomplete if (shift && event.keyCode == 50) # check what @ symbol charcode is?
    .keyup (event) ->
      shift = false if !event.shiftKey

$ -> App.usernameAutocomplete = new App.UsernameAutocomplete()
