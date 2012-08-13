App.PhotoUploader = class PhotoUploader
  settings: null

  constructor: (settings) ->
    @settings = settings

    @settings.form = @settings.button.closest("form")
    @settings.progressBar = @settings.form.find(".progress")
    @settings.errors = @settings.form.find(".uploadError")
    @settings.button.change(=> @doUpload())
    @settings.styledButton.click(=> @settings.button.click()) if @settings.styledButton[0]?

  doUpload: ->
    xhr = new XMLHttpRequest()
    fd = new FormData(@settings.form[0])

    @settings.errors.hide()
    @settings.progressBar.hide()

    files = @settings.button[0].files
    error = false
    $(files).each(->
      fileSize = (Math.round(this.size * 100 / (1024 * 1024)) / 100).toString()
      if fileSize > 10
        @settings.errors.html("Uploaded file should be not bigger than 10 MBs.").show()
        error = true
        return false
    )

    return if error

    @settings.progressBar.show()

    self = @

    # event listners
    xhr.upload.addEventListener("progress", (evt) ->
      if evt.lengthComputable && self.settings.progressBar[0]?
        percentComplete = Math.round(evt.loaded * 100 / evt.total)

        if percentComplete == 100
          self.settings.progressBar.find(".bar").html("Processing images...")

        self.settings.progressBar.find(".bar").css("width", percentComplete.toString() + '%')
    , false)
    xhr.addEventListener("load", (evt) ->
      self.settings.onSuccess(evt.target.responseText) if self.settings.onSuccess?
    , false)
    xhr.addEventListener("error", ->
      alert("error!")
    , false)
    xhr.addEventListener("abort", ->
      alert("abort!")
    , false)

    xhr.open("POST", @settings.form.attr("action"))
    header = $('meta[name="csrf-token"]').attr('content')
    xhr.setRequestHeader("X-CSRF-Token", header)
    xhr.send(fd)