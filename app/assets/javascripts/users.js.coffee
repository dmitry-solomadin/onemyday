# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(->
  return if not App.util.isPage "users", "edit_current"

  $("#facebook").off("toggle-condition")
  $("#facebook").on("toggle-condition", ->
    if $("#facebook").hasClass("active")
      $("#onealert").showModal(
        header: "Disconnect Facebook"
        body: "If you disconnect Facebook, you will not be able to login with Facebook."
        okay: ->
          $("#facebook").trigger("allow")
          window.location = "/auth/facebook/destroy"
      )
    else
      $("#facebook").trigger("allow")
  )

  $("#twitter").off("toggle-condition")
  $("#twitter").on("toggle-condition", ->
    if $("#twitter").hasClass("active")
      $("#onealert").showModal(
        header: "Disconnect Twitter"
        body: "If you disconnect Twitter, you will not be able to login with Twitter."
        okay: ->
          $("#twitter").trigger("allow")
          window.location = "/auth/twitter/destroy"
      )
    else
      $("#twitter").trigger("allow")
  )

  $("#facebook").on("after-toggle", ->
    if $("#facebook").hasClass("active")
      window.location = "/auth/facebook"
  )

  $("#twitter").on("after-toggle", ->
    if $("#twitter").hasClass("active")
      window.location = "/auth/twitter"
    else
      $("#onealert").modal()
  )

  new App.PhotoUploader
    onSuccess: -> window.location.reload()
    button: $("#avatarUploadButton")
    styledButton: $("#avatarUploadStyledButton")
)

$(->
  return if not App.util.isPage "users", "show"

  $("#userTabs a").on("click", ->
    $(@).closest("ul").find("li").removeClass("selected")
    $(@).closest("li").addClass("selected")
  )

  $('#storiesContainer').masonry
    itemSelector: '.smallStory'

  $(document).on("mouseenter", "#storiesContainer > .unpublished, #storiesContainer > .own", -> $(@).find(".imageHoverMenu").fadeIn('fast'))
  $(document).on("mouseleave", "#storiesContainer > .unpublished, #storiesContainer > .own", -> $(@).find(".imageHoverMenu").fadeOut('fast'))
)