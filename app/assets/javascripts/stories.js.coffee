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
        $(@).animate({left: 0}, 'fast')
        $(@).removeClass("btn-foxtrot")
      )
      stepTwo()
  )

  stepOne = ->
    $("#newStory .stepTwo").fadeOut()

  stepTwo = ->
    $("#newStory .stepTwo").fadeIn()

  $("#goToPhotoUpload").click(->
    stepPhoto()
  )

  stepPhoto = ->
    $(".overallInfo").css(position: "absolute")
    $(".overallInfo").animate(
      left: -1000
    )
    $(".photoUpload").show()

    new PhotoUploader().init()
)

class PhotoUploader
  init: ->
    $("#photoUploadButton").after(
      "<input type='button' class='btn btn-large btn-foxtrot f18' id='photoUploadStyledButton' value='Upload photo'>")
    $("#avatarUploadLi").wrap(
      "<form id='photoUploadForm' enctype='multipart/form-data' method='post'
       action='/upload_photo")

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

    file = $('#photoUploadButton')[0].files[0]
    fileSize = (Math.round(file.size * 100 / (1024 * 1024)) / 100).toString()
    if fileSize > 10
      $("#photoUploadError").html("Uploaded file should be not bigger than 10 MBs.").show()
      return
    else
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
    xhr.send(fd)

  onUploadSuccess: ->
    alert "Okay, we have a major success!"

