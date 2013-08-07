App.PhotoUploader = class PhotoUploader
  # todo we still need to implement 10Mb restriction
  constructor: (settings) ->
    settings.formData = {} unless settings.formData
    console.log $(settings.btnSelector)
    $(settings.btnSelector).each ->
      btn = $(@)
      totalFiles = 0
      uploadedFiles = 0
      datas = []

      customProgressBar = btn.parents(".uploadButtonDiv").find("#customProgressBar")

      btn.fileupload
        dataType: 'html'
        formData: settings.formData
        submit: (e, data) ->
          totalFiles++
          uploader = $(@)
          if settings.onSubmit
            datas.push data
            if data.originalFiles.length is totalFiles
              settings.onSubmit(uploader, datas)
          else
            uploader.fileupload('send', data)
          return false
        start: (e, data) ->
          customProgressBar.show()
        progressall: (e, data) ->
          progress = parseInt(data.loaded / data.total * 100, 10)
          customProgressBar.find('.bar').css 'width', "#{progress}%"
          customProgressBar.find('.barText').html($("#processingImages").val()) if progress is 100
        done: (e, data) ->
          uploadedFiles++
          if uploadedFiles is totalFiles
            customProgressBar.hide()
            totalFiles = 0
            uploadedFiles = 0
            datas = []
          settings.onDone(data.result)
