# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  $.rails.requiredInputSelector = 'input[name][required]:not([disabled]),textarea[name][required]:not([disabled]),input[name][req]:not([disabled])'

  $("#userMenu").on('hover', -> $('#userDropdown').css("width", $("#userMenu").width()))

  $('.storiesContainer').masonry
    itemSelector: '.smallStory'

  if $('.pagination')[0]
    $(window).scroll ->
      url = $('.pagination .next_page a').attr('href')
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').text("Loading more stories...")
        $.getScript(url)

    $(window).scroll()

  $("#navbarSearch").focus(->
    $(@).css(backgroundColor: "#ffffff")
  ).blur(->
    $(@).css(backgroundColor: "#eaeaea")
  )

  # Google analytics.
  if !$("#ga")[0]
    js = $("<script id='ga' src='http://www.google-analytics.com/ga.js'></script>")
    $("script:first").parent().prepend(js)

  class Home
    constructor: ->
      $(".tooltipize").tooltip()

    onSearchSubmit: ->
      $.trim($("#navbarSearch").val()).length > 0

    onLoginSubmit: ->
      $("#loginPassword, #loginEmail").removeClass("error_field").removeAttr("placeholder")
      hasError = false
      if $.trim($("#loginEmail").val()).length == 0
        $("#loginEmail").addClass("error_field").attr("placeholder", $("#loginEmail").data("err-text"))
        hasError = true
      if $.trim($("#loginPassword").val()).length == 0
        $("#loginPassword").addClass("error_field").attr("placeholder", $("#loginPassword").data("err-text"))
        hasError = true
      return not hasError

    hideStoryMessage: ->
      $(".photoHeader, .photoHeaderSpan").slideUp("normal")
      $.cookie('hide_story_message', 'true');

  App.home = new Home()
