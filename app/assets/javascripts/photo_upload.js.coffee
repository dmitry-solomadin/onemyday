App.PhotoUploader = class PhotoUploader
  settings: null

  constructor: (settings) ->
    @settings = settings

    @settings.form = @settings.button.closest("form")
    @settings.progressBar = @settings.form.find(".progress")
    @settings.barText = @settings.progressBar.find(".barText")
    @settings.errors = @settings.form.find(".uploadError")
    @settings.button.change(=> @doUpload())
    if @settings.styledButton[0]?
      @settings.styledButton.click =>
        if @settings.validate? then @settings.validate(=> @settings.button.click()) else @settings.button.click()

  doUpload: ->
    @settings.errors.hide()
    @settings.progressBar.hide()

    @settings.files = @settings.button[0].files
    return if @settings.files.length == 0

    for file in @settings.files
      fileSize = (Math.round(file.size * 100 / (1024 * 1024)) / 100).toString()
      if fileSize > 10
        @settings.errors.html("Uploaded file should be not bigger than 10 MBs.").show()
        return


    if @settings.preUploadRequest?
      @settings.barText.html($("#preparingImages").val())
      @settings.preUploadRequest =>
        @sendRequest($("#storyId").val())
    else
      @sendRequest($("#storyId").val())

  sendRequest: (storyId) ->
    for file, i in @settings.files
      xhr = new XMLHttpRequest()

      formData = new FormData()
      formData.append("file_bean", file)
      formData.append("story_id", storyId) if storyId

      @settings.barText.html("")
      @settings.progressBar.show()

      @assignEventListeners(xhr)

      xhr.open("POST", @settings.form.attr("action"))
      xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'))
      xhr.send(formData)

  assignEventListeners: (xhr) ->
    settings  = @settings
    bar = settings.progressBar.find(".bar")

    xhr.upload.addEventListener("progress", (evt) ->
      percentPerFile = 100 / settings.files.length
      if evt.lengthComputable && settings.progressBar[0]?
        percentComplete = Math.round(evt.loaded * percentPerFile / evt.total)

      currentPercent = Math.round(100 * bar.width() / bar.offsetParent().width())
      settings.barText.html($("#processingImages").val()) if currentPercent == 100

      bar.css("width", "#{currentPercent + percentComplete}%")
    , false)
    xhr.addEventListener("load", (evt) ->
      settings.onSuccess(evt.target.responseText) if settings.onSuccess?
    , false)
    xhr.addEventListener("error", ->
      alert("error!")
    , false)
    xhr.addEventListener("abort", ->
      alert("abort!")
    , false)