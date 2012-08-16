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

  $("#addCommentTextarea").keyup(->
    if $.trim($(@).val()).length == 0
      $("#addCommentSubmit").attr("disabled", "disabled")
    else
      $("#addCommentSubmit").removeAttr("disabled")
  )
)


# New story page
$(->
  return if not App.util.isPage "stories", "new"

  $("#date").datepicker(
    dateFormat: "dd-mm-yy"
  )

  $("#photoUploadStoryDate").datepicker(
    dateFormat: "dd-mm-yy"
  )

  $(".share").click(->
    all = $(".shareDiv > .share")
    visible = all.filter(":visible")

    all.removeClass("firstShare").eq(0).addClass("firstShare")

    storyTypeSelected = visible.length == 1

    if storyTypeSelected
      $("#type").val("")
      all.css("position", "static")
        .addClass("btn-foxtrot")
        .fadeIn()
      stepOne()
    else
      $("#type").val($(@).data("type"))
      top = $(@).position().top
      left = $(@).position().left
      all.not(@).fadeOut('fast', =>
        $(@).css(
          position: "absolute"
          top: top
          left: left
        ).addClass("firstShare")
          .animate(left: $(".container").offset().left, 'fast', => $(@).css(position: "static"))
          .removeClass("btn-foxtrot")
      )
      stepTwo()
  )

  stepOne = ->
    $("#newStory .stepTwo").fadeOut()

  stepTwo = ->
    $("#newStory .stepTwo").fadeIn()


  App.Stories.stepPhoto = (createdStoryId)->
    $("#createdStoryId").val(createdStoryId)
    $(".overallInfo").fadeOut("fast", ->
      $("#photoUploadStoryTitle").val($("#title").val())
      $("#photoUploadStoryDate").val($("#date").val())

      $("#photoUploadDiv").show()

      new App.PhotoUploader
        onSuccess: storyHelper.onPhotoUploadSuccess
        button: $("#photoUploadButton")
        styledButton: $("#photoUploadStyledButton")
    )
)

class Story
  groupTypes:
    left:
      {name: "left", blockId: "#leftRightGroup", orientationToggleId: ".leftOrientation"}
    right:
      {name: "right", blockId: "#rightLeftGroup", orientationToggleId: ".rightOrientation"}
    center:
      {name: "center", blockId: "#centerGroup", orientationToggleId: ".centerOrientation"}

  onPhotoUploadSuccess: (data) =>
    $("#story").show()
    @.showPublish()
    $("#photoDiv").html(data)

    dataValid = $("#photoDiv > #uploadedPhotoData").children().length > 0
    if dataValid
      $("#customProgressBar").hide()

      storyHelper.eachPhoto (index) ->
        evenIndex = index == 0 or index % 2 == 0
        groupOrientation = if evenIndex then storyHelper.groupTypes.left else storyHelper.groupTypes.right

        storyHelper.addGroup(groupOrientation, storyHelper.grabImageData(index))

  showPublish: ->
    $("#storyPublish").show()
    $("#storyPublishButton").click(->
      postParams =
        "authenticity_token": $('meta[name="csrf-token"]').attr('content')
        "story[id]": $("#createdStoryId").val()
        "story[title]": $("#photoUploadStoryTitle").val()
        "story[date]": $("#photoUploadStoryDate").val()
        "story[published]": "t"

      $(".storyGroup").each((index) ->
        postParams["story[story_photos_attributes][#{index}][id]"] = $(this).data('id')
        postParams["story[story_photos_attributes][#{index}][caption]"] = $(this).find('.text').html()
        postParams["story[story_photos_attributes][#{index}][date_text]"] = $(this).find('.time').html()
        postParams["story[story_photos_attributes][#{index}][orientation]"] = $(this).data("orientation")
      )

      App.util.post($(@).parents("form:first").attr("action"), postParams)
    )

  createGroup: (type, photoData, time, text) ->
    text = if text? then text else "Tell the story of this photo. Click to edit."
    time = if time? then time else if photoData.data("date") and photoData.data("date") != "" then photoData.data("date") else "08:10 am"

    newGroup = $(type.blockId).clone()
    newGroup[0].id = "group#{photoData[0].id}"
    newGroup.addClass("storyGroup").addClass(type.name).data("orientation", type.name)
    newGroup.data("id", photoData[0].id)

    #init image orientation toggles
    orientationToggles = $("#imageHoverMenuPlaceholder").clone()
    orientationToggles[0].id = ""
    newGroup.find(".imagePlace").append(orientationToggles)
    orientationToggles.find(type.orientationToggleId).addClass("active")

    for own groupName, groupProps of @.groupTypes
      clickFunc = (groupProps) => => @.changeGroup(groupProps, photoData)
      orientationToggles.find(groupProps.orientationToggleId).click(clickFunc(groupProps))

    newGroup.find(".imagePlace").append(@grabImage(type, photoData)).mouseenter(->
      $(@).find(".imageHoverMenu").fadeIn("fast")
    ).mouseleave(->
      $(@).find(".imageHoverMenu").fadeOut("fast")
    )

    newGroup.find(".textPlace > .time").on("click.editTime",-> storyHelper.editTime(@)).html(time)
    newGroup.find(".textPlace > .text").on("click.editText",-> storyHelper.editCaption(@)).html(text)

    newGroup

  changeGroup: (type, photoData) ->
    oldGroup = $("#group#{photoData[0].id}")
    unless oldGroup[0]?
      return

    group = @.createGroup(type, photoData)
    group.find(".textPlace .text").html(oldGroup.find(".textPlace .text").html())
    group.find(".textPlace .time").html(oldGroup.find(".textPlace .time").html())

    oldGroup.fadeOut("fast")
    oldGroup.replaceWith group

    group.fadeIn("fast")
    @initializeGroup group

  addGroup: (type, photoData, time, text) ->
    if $("#group#{photoData[0].id}")[0]?
      return

    group = @.createGroup(type, photoData, time, text)

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
        "margin-left": dottedMarginLeft + 20
      )
    else
      group.find(".span0").css("height", group.find(".imagePlace img").height() + 40)

  grabImage: (type, photoData) ->
    return @grabSmallerImage(photoData) if type.name == "left" or type.name == "right"
    return @grabLargerImage(photoData) if type.name == "center"

  grabSmallerImage: (photoData) ->
    "<img src='#{photoData.data("medium-image")}' style='height:#{photoData.data("medium-height")}px; width:#{photoData.data("medium-width")}px'>"

  grabLargerImage: (photoData) ->
    "<img src='#{photoData.data("large-image")}' style='height:#{photoData.data("large-height")}px; width:#{photoData.data("large-width")}px'>"

  grabImageData: (index) ->
    $("#uploadedPhotoData > input").eq(index)

  eachPhoto: (callback)->
    $("#uploadedPhotoData > input").each (index)->
      callback index

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
    ampm = @.extractAmPmSwitch $.trim($timeDiv.html())

    $timeDiv.html(
      "<input class='timeEdit' value='#{time}'/>#{ampm}"
    )
    $timeDiv.find(".timeEdit").inputmask({ "mask": "h:s"})[0].focus()

    $timeDiv.off("click.editTime")
    $(document).on("click.documentEditTime", (event) =>
      if event and ($.contains(timeDiv, event.target) or $(event.target).hasClass("time"))
        return

      $timeDiv.html($timeDiv.find(".timeEdit").val().replace(/_/, "") + @.extractAmPm($timeDiv.find(".timeEditAmPm")[0]))
      $(document).off("click.documentEditTime")
      $timeDiv.on("click.editTime", => storyHelper.editTime(timeDiv))
    )

  extractAmPm: (timeEditAmPm) ->
    if timeEditAmPm? then " " + $(timeEditAmPm).find("option:selected").val() else ""

  extractAmPmSwitch: (time) ->
    if time.search(/(am|pm)/) == -1
      return ""

    am = time.search(/pm/) == -1

    return "<select class='timeEditAmPm'><option value='am' #{'selected=selected' if am}>am</option><option value='pm' #{'selected=selected' if !am}>pm</option></select>"

storyHelper = new Story
