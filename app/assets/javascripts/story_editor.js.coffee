# New or Edit page
$ ->
  return if not App.util.isPage("stories", "new") and not App.util.isPage("stories", "edit")

  $(".crosspost > input").on "click", ->
    $(@).toggleClass("disabled")
    if $(@).hasClass("disabled")
      $(@).tooltip('disable').tooltip('hide')
    else
      $(@).tooltip('enable').tooltip('show')

  $("#photoUploadTags").select2
    multiple: true
    initSelection : (element, callback) ->
      data = []
      $(element.val().split(",")).each ->
        data.push id: @, text: @
      callback(data)
    tokenSeparators:[',', ' ']
    ajax:
      url: "/tags"
      dataType: 'json'
      data: (term, page) ->
        q: term
      results: (data, page) ->
        res = {}
        res.results = []
        $(data).each -> res.results.push id:@, text:@
        res

# New story page
$ ->
  return unless App.util.isPage "stories", "new"

  $('.photoUploadButton').on "click", -> return false unless storyHelper.validate()

  regularOnSubmit = (uploader, datas, storyId) ->
    for data, index in storyHelper.sortFileDatasByName(datas)
      data.formData =
        "story_id": storyId
        "element_order": storyHelper.photoCount() + index
      uploader.fileupload('send', data)

  App.photoUploader = new App.PhotoUploader
    btnSelector: ".photoUploadButton"
    onSubmit: (uploader, datas) ->
      storyData =
        "story[title]": $("#photoUploadStoryTitle").val()
        "story[tag_list]": $("#photoUploadTags").val()
      if $(".photoUploadButton").data("story-created")
        regularOnSubmit uploader, datas, $("#storyId").val()
      else
        $.post $("#storyForm").attr("action"), storyData, (storyId) ->
          regularOnSubmit uploader, datas, storyId
          $(".photoUploadButton").data("story-created", "true")
          if window.history
            window.history.pushState({foo: 'bar'}, 'Title', "/stories/#{storyId}/edit")
    onDone: (result) ->
      storyHelper.onPhotoUploadSuccess(result)
      $("#storySaveExp").show()

# Edit story page
$ ->
  return if not App.util.isPage "stories", "edit"

  App.photoUploader = new App.PhotoUploader
    btnSelector: ".photoUploadButton"
    onSubmit: (uploader, datas) ->
      for data, index in storyHelper.sortFileDatasByName(datas)
        data.formData =
          "story_id": $("#storyId").val()
          "element_order": storyHelper.photoCount() + index
        uploader.fileupload('send', data)
    onDone: (result) -> storyHelper.onPhotoUploadSuccess(result)

  storyHelper.appendPhotos()
  storyHelper.showPublish()
