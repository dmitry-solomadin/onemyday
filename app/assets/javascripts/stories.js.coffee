$(->
  # defining global namespace for stories
  App.Stories = {}

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
      new App.PhotoUploader(storyHelper.onPhotoUploadSuccess)
    )
)

class Story
  groupTypes:
    left:
      {blockId: "#leftRightGroup", orientationToggleId: ".leftOrientation"}
    right:
      {blockId: "#rightLeftGroup", orientationToggleId: ".rightOrientation"}
    center:
      {blockId: "#centerGroup", orientationToggleId: ".centerOrientation"}

  onPhotoUploadSuccess: (data) =>
    $("#story").show()
    @.showPublish()
    $("#photoDiv").html(data)

    dataValid = $("#photoDiv > #uploadedPhotoData").children().length > 0
    if dataValid
      $("#customProgressBar").hide()

      storyHelper.eachPhoto (index) ->
        evenIndex = index == 0 or index % 2 == 0

        imageData = storyHelper.grabImageData(index)
        groupOrientation = if evenIndex then storyHelper.groupTypes.left else storyHelper.groupTypes.right
        defaultText = "Tell the story of this photo. Click to edit."
        time = if imageData.data("date") and imageData.data("date") != "" then imageData.data("date") else "08:10 am"
        imageId = imageData[0].id

        storyHelper.addGroup(groupOrientation, imageId, storyHelper.grabImage(index), time, defaultText)

  showPublish: ->
    $("#storyPublish").show()
    $("#storyPublishButton").click(->
      postParams =
        "authenticity_token": $('meta[name="csrf-token"]').attr('content')
        "story[id]": ""
        "story[title]": $("#photoUploadStoryTitle").val()
        "story[date]": $("#photoUploadStoryDate").val()

      $(".storyGroup").each((index) ->
        postParams["photos[#{index}][id]"] = $(this).data('id')
        postParams["photos[#{index}][catpion]"] = $(this).find('.text').html()
        postParams["photos[#{index}][date]"] = $(this).find('.time').html()
      )

      App.util.post($(@).parents("form:first").attr("action"), postParams)
    )

  createGroup: (type, photoId, photo, time, text) ->
    newGroup = $(type.blockId).clone()
    newGroup[0].id = "group#{photoId}"
    newGroup.addClass("storyGroup")
    newGroup.data("id", photoId)

    #init image orientation toggles
    orientationToggles = $("#imageHoverMenuPlaceholder").clone()
    orientationToggles[0].id = ""
    newGroup.find(".imagePlace").append(orientationToggles)
    orientationToggles.find(type.orientationToggleId).addClass("active")

    for own groupName, groupProps of @.groupTypes
      clickFunc = (groupProps) => => @.changeGroup(groupProps, photoId, photo, time, text)
      orientationToggles.find(groupProps.orientationToggleId).click(clickFunc(groupProps))

    newGroup.find(".imagePlace").append(photo).mouseenter(->
      $(@).find(".imageHoverMenu").fadeIn("fast")
    ).mouseleave(->
      $(@).find(".imageHoverMenu").fadeOut("fast")
    )

    newGroup.find(".textPlace > .time").on("click.editTime",-> storyHelper.editTime(@)).html(time)
    newGroup.find(".textPlace > .text").on("click.editText",-> storyHelper.editCaption(@)).html(text)

    newGroup

  changeGroup: (type, photoId, photo, time, text) ->
    oldGroup = $("#group#{photoId}")
    unless oldGroup[0]?
      return

    group = @.createGroup(type, photoId, photo, time, text)
    oldGroup.fadeOut("fast")
    oldGroup.replaceWith group
    group.fadeIn("fast")
    group.find(".span0").css("height", group.find(".imagePlace").height() + 40)

  addGroup: (type, photoId, photo, time, text) ->
    if $("#group#{photoId}")[0]?
      return

    group = @.createGroup(type, photoId, photo, time, text)

    $("#story").append group
    group.show()
    group.find(".span0").css("height", group.find(".imagePlace").height() + 40)

  grabImage: (index) ->
    imageDataInput = $("#uploadedPhotoData > input").eq(index)
    "<img src='#{imageDataInput.val()}' style='height:#{imageDataInput.data('height')}px}'>"

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
