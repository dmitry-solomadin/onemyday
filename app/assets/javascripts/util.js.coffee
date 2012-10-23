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

App.util.isPage = (controller, action) ->
  return $("body").data("controller") == controller and $("body").data("action") == action

$ = jQuery
$.fn.showModal = (settings) ->
  this.find(".modal-header h3").html settings.header
  this.find(".modal-body").html settings.body
  this.find(".modal-footer .modal-okay").click =>
    settings.okay() if settings.okay
    this.modal("hide")
  this.find(".modal-footer .modal-cancel").click =>
    settings.cancel() if settings.cancel
    this.modal("hide")
  this.modal()

$.fn.combinedHover = (settings) ->
  trigger = @;
  additionalTriggers = settings.additionalTriggers

  updateHoverCount = (toAdd) -> trigger[0].hovercount = trigger[0].hovercount + toAdd
  addHoverCount = -> updateHoverCount(1)
  removeHoverCount = ->
    updateHoverCount(-1)
    window.setTimeout(->
      settings.offTrigger() if trigger[0].hovercount == 0
    , 100)

  trigger[0].hovercount = 0;

  if settings.live
    $(document).on('mouseenter', additionalTriggers, -> addHoverCount())
      .on('mouseleave', additionalTriggers, -> removeHoverCount())
  else
    $(additionalTriggers).on('mouseenter', -> addHoverCount()).on('mouseleave', -> removeHoverCount())

  trigger.on('mouseenter', ->
    addHoverCount()
    settings.onTrigger()
  ).on('mouseleave', -> removeHoverCount())
  trigger


