# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(->
  $('#userDropdown').css("width", $("#userMenu").width())

  $('#storiesContainer').masonry
    itemSelector: '.smallStory'

  $("#navbarSearch").focus(->
    $(@).css(backgroundColor: "#ffffff")
  ).blur(->
    $(@).css(backgroundColor: "#eaeaea")
  )

  $(".smallStory").each(-> $(@).width($(@).find("img").width()))
)