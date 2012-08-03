$(->
  # defining global namespace for stories
  App.Stories = {}

  $("#date").datepicker(
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
    $(".overallInfo").css(position: "absolute")
    $(".overallInfo").animate(
      left: -1000
    )
    $("#photoUploadDiv").show()

    new PhotoUploader().init()
)

class PhotoUploader
  init: ->
    $("#photoUploadButton").change(=>
      @.doUpload()
    )

    $("#photoUploadStyledButton").click(->
      $("#photoUploadButton").click()
    )

  doUpload: ->
    xhr = new XMLHttpRequest()
    fd = new FormData($('#photoUploadForm')[0])

    $("#photoUploadError").hide()
    $("#customProgressBar").hide()

    files = $('#photoUploadButton')[0].files
    error = false
    $(files).each(->
      fileSize = (Math.round(this.size * 100 / (1024 * 1024)) / 100).toString()
      if fileSize > 10
        $("#photoUploadError").html("Uploaded file should be not bigger than 10 MBs.").show()
        error = true
        return false
    )

    return if error

    $("#customProgressBar").show()

    # event listners
    xhr.upload.addEventListener("progress", (evt) ->
      if evt.lengthComputable
        percentComplete = Math.round(evt.loaded * 100 / evt.total)

        $('#customProgressBar .uploadify-progress-bar').css("width", percentComplete.toString() + '%')
    , false)
    xhr.addEventListener("load", (evt) =>
      @.onUploadSuccess(evt.target.responseText)
    , false)
    xhr.addEventListener("error", ->
      alert("error!")
    , false)
    xhr.addEventListener("abort", ->
      alert("abort!")
    , false)

    xhr.open("POST", "/upload_photo")
    header = $('meta[name="csrf-token"]').attr('content')
    xhr.setRequestHeader("X-CSRF-Token", header)
    xhr.send(fd)

  onUploadSuccess: (data) ->
    $("#story").show()
    $("#photoDiv").html(data)

    dataValid = $("#photoDiv > #uploadedPhotoData").children().length > 0
    if dataValid
      $("#customProgressBar").hide()

      storyHelper.addGroup(storyHelper.groupType.left, storyHelper.grabImage(0), "8:10 am", $("#lorem").html())
      storyHelper.addGroup(storyHelper.groupType.right, storyHelper.grabImage(1), "9:45 am", $("#lorem").html())

class Story
  groupType: {left: "#leftRightGroup", right: "#rightLeftGroup"}

  addGroup: (type, photo, time, text) ->
    newGroup = $(type).clone()
    newGroup[0].id = ""
    newGroup.find(".imagePlace").append(photo)
    newGroup.find(".textPlace > .time").html(time)
    newGroup.find(".textPlace > .text").html(text)
    $("#story").append newGroup

    newGroup.show()

    newGroup.find(".imagePlace > img").load(=>
      newGroup.find(".span0").css("height", newGroup.find(".imagePlace").height() + 40)
    )

  grabImage: (index) ->
    return "<img src='#{$("#uploadedPhotoData > input").eq(index).val()}'>"


storyHelper = new Story
