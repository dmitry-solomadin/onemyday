$(->
  # defining global namespace for stories
  App.Stories = {}
)

# Show story page
$(->
  return if not App.util.isPage "stories", "show"

  $("#storyLike").click ->
    if $(@).hasClass("btn-foxtrot")
      $(@).removeClass("btn-foxtrot").find("span").html("Like")
    else
      $(@).addClass("btn-foxtrot").find("span").html("Liked!")

  $(".storyGroup").each(->
    storyHelper.initializeGroup $(@)
  )

  # Initialize twitter button.
  if !$("#twitter-wjs")[0]
    js = $("<script id='twitter-wjs' src='//platform.twitter.com/widgets.js'></script>")
    $("script:first").parent().prepend(js)

  if !$("#facebook-jssdk")[0]
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
)

# New or Edit page
$(->
  return if not App.util.isPage("stories", "new") and not App.util.isPage("stories", "edit")

  $("#photoUploadTags").select2
    multiple: true
    initSelection : (element, callback) ->
      data = [];
      $(element.val().split(",")).each ->
        data.push({id: @, text: @});
      callback(data)
    tokenSeparators:[',', ' ']
    ajax:
      url: "/tags"
      dataType: 'json'
      data: (term, page) ->
        q: term
      results: (data, page) ->
        res = {}
        res.results = []
        $(data).each(-> res.results.push({id:@, text:@}))

        res
)

# New story page
$(->
  return if not App.util.isPage "stories", "new"

  $("#photoUploadStoryDate").datepicker dateFormat: "dd-mm-yy"

  new App.PhotoUploader
    onSuccess: storyHelper.onPhotoUploadSuccess
    validate: storyHelper.validate
    button: $("#photoUploadButton")
    styledButton: $("#photoUploadStyledButton")
)

# Explore stories page
$(->
  return if not App.util.isPage "stories", "explore"

  filterStories = ->
    url = $("#advSearch").data("url") + ".js"
    tag = $("#tags .active").data("type")
    filterType = $("#filter .active").data("type")

    req = $.ajax
      url: url
      method: "GET"
      cache: false
      dataType: "html"
      data:
        {t: tag, ft: filterType}
      success: (data) -> $("#exploreStoriesContainer").html(data)

  $(document).on("click", "#tags .btn, #filter .btn", filterStories)
)

# Edit story page
$(->
  return if not App.util.isPage "stories", "edit"

  $("#photoUploadStoryDate").datepicker
    dateFormat: "dd-mm-yy"

  new App.PhotoUploader
    onSuccess: storyHelper.onPhotoUploadSuccess
    validate: storyHelper.validate
    button: $("#photoUploadButton")
    styledButton: $("#photoUploadStyledButton")

  storyHelper.appendPhotos()

  storyHelper.showPublish()
)

class Story
  groupTypes:
    left:
      {name: "left", blockId: "#leftRightGroup", orientationToggleId: ".leftOrientation"}
    right:
      {name: "right", blockId: "#rightLeftGroup", orientationToggleId: ".rightOrientation"}
    center:
      {name: "center", blockId: "#centerGroup", orientationToggleId: ".centerOrientation"}

  validate: (callback) =>
    App.formErrors.clear()
    valid = true

    if $("#photoUploadStoryTitle").val().length == 0
      valid = false
      App.formErrors.add "photoUploadStoryTitle", "Please, enter story title."

    if $("#photoUploadStoryDate").val().length == 0
      valid = false
      App.formErrors.add "photoUploadStoryDate","Please, enter story date."

    callback() if valid

  onPhotoUploadSuccess: (data) =>
    $("#shouldCreateStory").remove();
    $("#storyId").val($("#createdStoryId").val())

    $("#story").show()
    @showPublish()
    $("#photoDiv").html(data)

    dataValid = $("#photoDiv > #uploadedPhotoData").find(".photo").length > 0
    if dataValid
      $("#customProgressBar").hide()

      @appendPhotos()

  appendPhotos: ->
    storyHelper.eachPhoto (index) ->
      groupData = storyHelper.grabImageData(index)
      evenIndex = index == 0 or index % 2 == 0

      groupOrientation = if evenIndex then storyHelper.groupTypes.left else storyHelper.groupTypes.right
      stringOrientation = $(groupData).data("orientation")
      switch stringOrientation
        when "left" then groupOrientation = storyHelper.groupTypes.left
        when "right" then groupOrientation = storyHelper.groupTypes.right
        when "center" then groupOrientation = storyHelper.groupTypes.center

      storyHelper.addGroup(groupOrientation, groupData)

    @refreshFlowControl()

  showPublish: ->
    $("#storyPublish").show()

    collectPostParams = ->
      postParams =
        "authenticity_token": $('meta[name="csrf-token"]').attr('content')
        "story[id]": $("#createdStoryId").val()
        "story[title]": $("#photoUploadStoryTitle").val()
        "story[date]": $("#photoUploadStoryDate").val()
        "story[tag_list]": $("#photoUploadTags").val()
        "story[published]": "t"

      $(".storyGroup").each (index) ->
        postParams["story[story_photos_attributes][#{index}][id]"] = $(this).data('id')
        postParams["story[story_photos_attributes][#{index}][caption]"] = $(this).find('.text').html()
        postParams["story[story_photos_attributes][#{index}][date_text]"] = $(this).find('.time').html()
        postParams["story[story_photos_attributes][#{index}][orientation]"] = $(this).data("orientation")
        postParams["story[story_photos_attributes][#{index}][photo_order]"] = index
        postParams["story[story_photos_attributes][#{index}][has_text]"] = if $(this).data("hideText") == "true" then false else true

      postParams

    $("#storyPublishButton").click ->
      storyHelper.validate =>
        postParams = collectPostParams()
        postUrl = $(@).data("publish-path")

        App.util.post postUrl, postParams

    $("#storyDraftButton").click ->
      storyHelper.validate =>
        postParams = collectPostParams()
        postParams["story[published]"] = "f"
        postUrl = $(@).data("publish-path")

        App.util.post postUrl, postParams

  createGroup: (type, photoData) ->
    text = if photoData.data("text") and photoData.data("text") != "" then photoData.data("text") else "Tell the story of this photo. Click to edit."
    time = if photoData.data("date") and photoData.data("date") != "" then photoData.data("date") else "08:10 am"

    newGroup = $(type.blockId).clone()
    newGroup[0].id = "group#{photoData[0].id}"
    newGroup.addClass("storyGroup").addClass(type.name).data("orientation", type.name)
    newGroup.data("id", photoData[0].id)

    #init hover menu
    hoverMenu = $("#imageHoverMenuPlaceholder").clone()
    hoverMenu[0].id = ""
    newGroup.find(".imagePlace").append(hoverMenu)
    hoverMenu.find(type.orientationToggleId).addClass("active")

    for own groupName, groupProps of @groupTypes
      clickFunc = (groupProps) => => @changeGroup(groupProps, photoData)
      hoverMenu.find(groupProps.orientationToggleId).click(clickFunc(groupProps))

    hoverMenu.find(".moveUp").click(=> @moveUp newGroup)
    hoverMenu.find(".moveDown").click(=> @moveDown newGroup)

    hoverMenu.find(".hasText").click(=> @hideTextClick newGroup)

    removePhotoLink = hoverMenu.find(".removePhoto")
    removePhotoLink.attr("href", removePhotoLink.data("href").replace("-1", photoData[0].id))

    newGroup.find(".imagePlace").append(@grabImage(type, photoData)).mouseenter(->
      $(@).find(".imageHoverMenu").fadeIn("fast")
    ).mouseleave(->
      $(@).find(".imageHoverMenu").fadeOut("fast")
    )

    newGroup.find(".textPlace > .time").on("click.editTime",-> storyHelper.editTime(@)).html(time)
    newGroup.find(".textPlace > .text").on("click.editText",-> storyHelper.editCaption(@)).html(text)

    if photoData.data("has-text") == true then @showText newGroup else @hideText newGroup

    newGroup

  changeGroup: (type, photoData) ->
    oldGroup = $("#group#{photoData[0].id}")
    unless oldGroup[0]?
      return

    group = @createGroup(type, photoData)

    if oldGroup.data("hideText") == "true" then @hideText group else @showText group

    group.find(".textPlace .text").html(oldGroup.find(".textPlace .text").html())
    group.find(".textPlace .time").html(oldGroup.find(".textPlace .time").html())

    oldGroup.fadeOut("fast")
    oldGroup.replaceWith group

    group.fadeIn("fast")
    @initializeGroup group
    @refreshFlowControl()

  addGroup: (type, photoData) ->
    if $("#group#{photoData[0].id}")[0]?
      return

    group = @createGroup(type, photoData)

    $("#story").append group
    @initializeGroup group

  initializeGroup: (group) ->
    group.show()
    if group.data("orientation") == "center"
      #align text and time to image
      image = group.find(".imagePlace img")
      imageMarginLeft = (image.parent().width() - image.width()) / 2

      group.find(".imagePlace").css("margin-left", imageMarginLeft)
      group.find(".textPlace").css("margin-left", imageMarginLeft)

      dottedMarginLeft = group.find(".span0").parent().width() / 2

      group.find(".span0").css(
        "height": 40
        "margin-left": dottedMarginLeft - 20
      )

      group.find(".text").css(width: group.find(".imagePlace img").width())
    else
      group.find(".span0").css("height", group.find(".imagePlace img").height() + 40)

  grabImage: (type, photoData) ->
    return @grabSmallerImage(photoData) if type.name == "left" or type.name == "right"
    return @grabLargerImage(photoData) if type.name == "center"

  grabSmallerImage: (photoData) ->
    "<img src='#{photoData.data("medium-image")}' style='height:#{photoData.data("medium-height")}px; width:#{photoData.data("medium-width")}px'>"

  grabLargerImage: (photoData) ->
    "<img src='#{photoData.data("large-image")}' style='height:#{photoData.data("large-height")}px; width:#{photoData.data("large-width")}px'>"

  grabImageData: (index) -> $("#uploadedPhotoData > .photo").eq(index)

  eachPhoto: (callback) -> $("#uploadedPhotoData > .photo").each (index) -> callback index

  eachGroup: (callback) -> $(".storyGroup").each (index) -> callback(@, index)

  photoCount: -> $("#uploadedPhotoData > .photo").length

  editCaption: (textDiv) ->
    $textDiv = $(textDiv)
    $textDiv.html("<textarea class='textEdit'>#{$textDiv.html()}</textarea>")

    $textDiv.off("click.editText")
    $textDiv.addClass("onceEdited")

    $(document).on("click.documentEditText", (event) =>
      if event and ($.contains(textDiv, event.target) or $(event.target).hasClass("text"))
        return

      $textDiv.html($textDiv.find("textarea").val())
      $(document).off("click.documentEditText")
      $textDiv.on("click.editText", => storyHelper.editCaption(textDiv))
    )

  editTime: (timeDiv) ->
    $timeDiv = $(timeDiv)
    time = $.trim($timeDiv.html()).replace(/\s(am|pm)/, "")
    ampm = @extractAmPmSwitch $.trim($timeDiv.html())

    $timeDiv.html(
      "<input class='timeEdit' value='#{time}'/>#{ampm}"
    )
    $timeDiv.find(".timeEdit").inputmask({ "mask": "h:s"})[0].focus()

    $timeDiv.off("click.editTime")
    $(document).on("click.documentEditTime", (event) =>
      if event and ($.contains(timeDiv, event.target) or $(event.target).hasClass("time"))
        return

      $timeDiv.html($timeDiv.find(".timeEdit").val().replace(/_/, "") + @extractAmPm($timeDiv.find(".timeEditAmPm")[0]))
      $(document).off("click.documentEditTime")
      $timeDiv.on("click.editTime", => storyHelper.editTime(timeDiv))
    )

  extractAmPm: (timeEditAmPm) ->
    if timeEditAmPm? then " " + $(timeEditAmPm).find("option:selected").val() else ""

  extractAmPmSwitch: (time) ->
    return "" if time.search(/(am|pm)/) == -1

    am = time.search(/pm/) == -1

    return "<select class='timeEditAmPm'><option value='am' #{'selected=selected' if am}>am</option><option value='pm' #{'selected=selected' if !am}>pm</option></select>"

  moveUp: (group) ->
    group.prev().before(group)
    @refreshFlowControl()

  moveDown: (group) ->
    group.next().after(group)
    @refreshFlowControl()

  hideTextClick: (group) ->
    if group.find(".hasText").hasClass("active") then @hideText(group) else @showText(group)

  hideText: (group) ->
    group.data("hideText", "true")
    group.css(float: 'left', clear: 'none')
    group.find(".textPlace").hide()
    group.find(".span0").css(border: "none", marginLeft: "10px", marginRight: "10px")
    group.find(".rightOrientation").hide()
    group.find(".leftOrientation").html("Side")
    group.find(".hasText").removeClass("active")

  showText: (group) ->
    group.data("hideText", "false")
    group.css(float: 'none', clear: 'both')
    group.find(".textPlace").show()
    group.find(".span0").css(border: "1px dotted gray", marginLeft: "20px", marginRight: "20px")
    group.find(".rightOrientation").show()
    group.find(".leftOrientation").html("Left")
    group.find(".hasText").addClass("active")

  refreshFlowControl: ->
    $(".moveUp, .moveDown").show()
    @eachGroup (group, index) =>
      $(group).find(".moveUp").hide() if index == 0
      $(group).find(".moveDown").hide() if index == (@photoCount() - 1)

storyHelper = new Story
