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
    @settings.uploadSegments = []

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
    self = this
    settings  = @settings
    bar = settings.progressBar.find(".bar")
    percentPart = 100 / settings.files.length

    xhr.upload.addEventListener("progress", (evt) ->
      return unless evt.lengthComputable and settings.progressBar[0]?

      percentComplete = Math.round(evt.loaded * percentPart / evt.total)

      if settings.uploadSegments.length < settings.files.length
        settings.uploadSegments.push(percentComplete)
      else
        minSegmentObj = self.findMinSegment()
        minIndex = minSegmentObj.index
        minSegment = minSegmentObj.min

        settings.uploadSegments[minIndex] = percentComplete if percentComplete > minSegment

      overallPercent = 0
      overallPercent += segment for segment in settings.uploadSegments

      # correct percents in case of 33.33 percent part.
      overallPercent = 100 if overallPercent == Math.round(percentPart) * settings.files.length

      settings.barText.html($("#processingImages").val()) if overallPercent == 100

      bar.css("width", "#{overallPercent}%")
    , false)
    xhr.addEventListener("load", (evt) ->
      settings.filesLoaded = settings.filesLoaded + 1
      @settings.progressBar.hide() if settings.files.length == settings.filesLoaded.length
      settings.onSuccess(evt.target.responseText) if settings.onSuccess?
    , false)
    xhr.addEventListener("error", ->
      alert("error!")
    , false)
    xhr.addEventListener("abort", ->
      alert("abort!")
    , false)

  findMinSegment: ->
    minSegment = null
    minSegmentIndex = -1
    for segment, index in @settings.uploadSegments
      if segment < minSegment or not minSegment
        minSegment = segment
        minSegmentIndex = index

    {min:minSegment, index:minSegmentIndex}