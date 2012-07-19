# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(->
  $("#date").datepicker()

  $(".share").click(->
    all = $(".shareDiv > .share")
    visible = all.filter(":visible")

    all.removeClass("firstShare")
    all.eq(0).addClass("firstShare")

    if visible.length == 1
      all.css("position", "static")
      all.addClass("btn-foxtrot")
      all.fadeIn()
      stepOne()
    else
      top = $(@).position().top
      left = $(@).position().left
      all.not(@).fadeOut('fast', =>
        $(@).css(
          position: "absolute"
          top: top
          left: left
        )
        $(@).addClass("firstShare")
        $(@).animate({left:0}, 'fast')
        $(@).removeClass("btn-foxtrot")
      )
      stepTwo()
  )

  stepOne = ->
    $("#newStory .hide").fadeOut()

  stepTwo = ->
    $("#newStory .hide").fadeIn()
)

