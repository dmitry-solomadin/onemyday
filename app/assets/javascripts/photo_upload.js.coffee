# todo generify!

App.PhotoUploader = class PhotoUploader
  onSuccess: null

  constructor: (onSuccessFunction) ->
    @.onSuccess = onSuccessFunction

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

    self = @

    # event listners
    xhr.upload.addEventListener("progress", (evt) ->
      if evt.lengthComputable
        percentComplete = Math.round(evt.loaded * 100 / evt.total)

        if percentComplete == 100
          $('#customProgressBar .bar').html("Processing images...")

        $('#customProgressBar .bar').css("width", percentComplete.toString() + '%')
    , false)
    xhr.addEventListener("load", (evt) ->
      self.onSuccess(evt.target.responseText) if self.onSuccess?
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