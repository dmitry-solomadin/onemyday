$(->
  App.Stories = {}
  # defining global namespace for stories

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
          .animate(left: 0, 'fast', => $(@).css(position: "static"))
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
    $(".photoUpload").show()

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
      else
    )

    return if error

    $("#customProgressBar").show()

    # event listners
    xhr.upload.addEventListener("progress", (evt) ->
      if evt.lengthComputable
        percentComplete = Math.round(evt.loaded * 100 / evt.total)

        $("#fancybox-content").find('#customProgressBar .uploadify-progress-bar').css("width", percentComplete.toString() + '%')
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
    $("#photoDiv").html(data)

