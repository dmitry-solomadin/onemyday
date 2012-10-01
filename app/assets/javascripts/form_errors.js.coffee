class App.FormErrors

  add: (key, msg) ->
    if @isEmpty()
      $("#form_errors_div").append("<div class='alert alert-error'><ul></ul></div>")

    $("#form_errors_div ul").append("<li class='errorLi' data-field-id='#{key}'>#{msg}</li>");
    @highlight()

  replace: (newHtml) ->
    $("#form_errors_div").replaceWith newHtml

    @clear() if @isEmpty()

    @highlight()

  highlight: ->
    $("#form_errors_div li.errorLi").each -> $("#" + $(@).data("field-id")).closest(".control-group").addClass("error")

  clear: ->
    $("#form_errors_div").html ""
    $(".control-group").removeClass("error")

  isEmpty: ->
    $("#form_errors_div").children().length == 0

$ -> App.formErrors = new App.FormErrors