class App.FormErrors

  replace: (newHtml) ->
    $("#form_errors_div").replaceWith newHtml

    @.clear() if @.isEmpty()

    fieldId = $("#form_errors_div").find("li.errorLi").data("field-id")
    $("#" + fieldId).parents(".control-group:first").addClass("error")

  clear: ->
    $("#form_errors_div").html ""
    $(".control-group").removeClass("error")

  isEmpty: ->
    $("#form_errors_div").children().length == 0

$ -> App.formErrors = new App.FormErrors