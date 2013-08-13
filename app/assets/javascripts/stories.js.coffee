# Show story page
$ ->
  return unless App.util.isPage "stories", "show"

  if window.location.hash
    showFacebookNoRights = window.location.hash.match(/showFacebookNoRights/)
    $("#showFacebookNoRights").show() if showFacebookNoRights

  if $("#likeWrapper")[0]
    $("#likeWrapper").combinedHover
      additionalTriggers: "#likeBox"
      onTrigger: ->
        $("#likeBox").css(zIndex: 1, display:"block")
        $("#likeBox").animate({opacity: 1, top: -50}, "fast")
      offTrigger: -> $("#likeBox").animate({opacity: 0, top: -65}, "fast", -> $(@).css(zIndex: -1, display:"none"))

  $("#likeBox img").tooltip
    placement: "bottom"

  $("#storyLike").click ->
    if $(@).hasClass("btn-foxtrot")
      $(@).removeClass("btn-foxtrot").find("span").html($(@).data("like"))
    else
      $(@).addClass("btn-foxtrot").find("span").html($(@).data("liked"))

  $(".storyGroup").each -> storyHelper.initializeGroup $(@)

  # Initialize twitter button.
  unless $("#twitter-wjs")[0]
    js = $("<script id='twitter-wjs' src='//platform.twitter.com/widgets.js'></script>")
    $("script:first").parent().prepend(js)

  unless $("#facebook-jssdk")[0]
    js = $("<script id='facebook-jssdk' src='//connect.facebook.net/en_US/all.js'></script>")
    $("script:first").parent().prepend(js)

  # Initialize facebook like button.
  window.fbAsyncInit = ->
    FB.init
      appId: $("#facebookAppId").val() # App ID
      channelUrl: "//#{$("#appHost").val()}/channel.html" # Channel File
      status: false # check login status
      cookie: true # enable cookies to allow the server to access the session
      xfbml: true  # parse XFBML

# Explore stories page
$ ->
  return if not App.util.isPage "stories", "explore"

  filterStories = ->
    url = $("#advSearch").data("url")
    tag = $("#tags .active").data("type")
    filterType = $("#filter .active").data("type")

    # todo we need something better here.
    if tag? then $.getScript("#{url}?t=#{tag}&ft=#{filterType}") else $.getScript("#{url}?ft=#{filterType}")

  $(document).on("click", "#tags .btn, #filter .btn", filterStories)

# Search stories page
$ ->
  return if not App.util.isPage "stories", "search"

  filterStories = ->
    url = $("#searchInnerContainer").data("url")
    query = $("#searchInnerContainer").data("query")
    filterType = $("#filter .active").data("type")

    $.getScript("#{url}?q=#{query}&ft=#{filterType}")

  $(document).on("click", "#filter .btn", filterStories)
