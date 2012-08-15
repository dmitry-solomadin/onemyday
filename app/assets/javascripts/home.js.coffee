# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(->
  $('#storiesContainer').masonry
    itemSelector: '.smallStory'


  $("#navbarSearch").focus(->
    $(@).css(backgroundColor: "#ffffff")
  ).blur(->
    $(@).css(backgroundColor: "#eaeaea")
  )

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

  $.fn.textfill = (options) ->
    fontSize = options.maxFontPixels
    maxHeight = $(@).parents(options.container).height()
    maxWidth = $(@).parents(options.container).width()
    textHeight
    textWidth
    loop
      @.css('font-size', fontSize)
      textHeight = @.height()
      textWidth = @.width()
      fontSize = fontSize - 1
      break unless (textHeight > maxHeight or textWidth > maxWidth) and fontSize > 3
    return @

  $(".smallStory").each(-> $(@).width($(@).find("img").width()))
#  $(".smallStory .title").each( -> $(@).textfill({ maxFontPixels: 24, container: ".text:first"}) );
)