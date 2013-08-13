$ ->

  class StoryHelper
    groupTypes:
      left: {name: "left", blockId: "#leftRightGroup", orientationToggleId: ".leftOrientation"}
      right: {name: "right", blockId: "#rightLeftGroup", orientationToggleId: ".rightOrientation"}
      center: {name: "center", blockId: "#centerGroup", orientationToggleId: ".centerOrientation"}

    validate: ->
      App.formErrors.clear()
      valid = true

      if $("#photoUploadStoryTitle").val().length == 0
        valid = false
        App.formErrors.add "photoUploadStoryTitle", $("#noStoryTitle").val()

      return valid

    onPhotoUploadSuccess: (data) =>
      $("#story").show()
      @showPublish()
      $("#photoDiv").html(data)

      $(".storyId").val($("#createdStoryId").val())

      dataValid = $("#photoDiv > #uploadedPhotoData").find(".photo").length > 0
      @appendPhotos() if dataValid

    appendPhotos: ->
      storyHelper.eachPhoto (index) ->
        groupData = storyHelper.grabImageData(index)
        evenIndex = index == 0 or index % 2 == 0

        groupOrientation = if evenIndex then storyHelper.groupTypes.left else storyHelper.groupTypes.right
        stringOrientation = $(groupData).data("orientation")
        switch stringOrientation
          when "left" then groupOrientation = storyHelper.groupTypes.left
          when "right" then groupOrientation = storyHelper.groupTypes.right
          when "center" then groupOrientation = storyHelper.groupTypes.center

        storyHelper.addGroup(groupOrientation, groupData)

      @refreshFlowControl()

    showPublish: ->
      $("#storyPublish").show()

      collectPostParams = ->
        # before collecting post params, let's close all editing textareas if user has forgot to do this.
        $(document).trigger("click.documentEditText")

        postParams =
          "authenticity_token": $('meta[name="csrf-token"]').attr('content')
          "story[id]": $("#createdStoryId").val()
          "story[title]": $("#photoUploadStoryTitle").val()
          "story[tag_list]": $("#photoUploadTags").val()
          "story[published]": "t"
        postParams.crosspost_facebook = not $("#crosspostFacebook").hasClass("disabled") if $("#crosspostFacebook")[0]
        postParams.crosspost_twitter = not $("#crosspostTwitter").hasClass("disabled") if $("#crosspostTwitter")[0]

        $(".storyGroup").each (index) ->
          shouldHideText = $(this).data("hideText") == "true" or storyHelper.isTextDefault($(this).find('.text').html())
          postParams["story[story_photos_attributes][#{index}][id]"] = $(this).data('id')
          postParams["story[story_photos_attributes][#{index}][caption]"] = $(this).find('.text').html()
          postParams["story[story_photos_attributes][#{index}][date_text]"] = $(this).find('.time').html()
          postParams["story[story_photos_attributes][#{index}][orientation]"] = $(this).data("orientation")
          postParams["story[story_photos_attributes][#{index}][element_order]"] = index
          postParams["story[story_photos_attributes][#{index}][has_text]"] = if shouldHideText then "false" else "true"

        postParams

      $("#storyPublishButton").click ->
        return unless storyHelper.validate()
        postParams = collectPostParams()
        postUrl = $(@).data("publish-path")
        App.util.post postUrl, postParams

      $("#storyDraftButton").click ->
        return unless storyHelper.validate()
        postParams = collectPostParams()
        postParams["story[published]"] = "f"
        postUrl = $(@).data("publish-path")
        App.util.post postUrl, postParams

    createGroup: (type, photoData) ->
      text = if photoData.data("text") and photoData.data("text") != "" then photoData.data("text") else $("#defaultStoryText").val()
      time = if photoData.data("date") and photoData.data("date") != "" then photoData.data("date") else "08:10 am"

      newGroup = $(type.blockId).clone()
      newGroup[0].id = "group#{photoData[0].id}"
      newGroup.addClass("storyGroup").addClass(type.name).data("orientation", type.name)
      newGroup.data("id", photoData[0].id)
      newGroup.data("order", photoData.data("order"))

      #init hover menu
      hoverMenu = $("#imageHoverMenuPlaceholder").clone()
      hoverMenu[0].id = ""
      newGroup.find(".imagePlace").append(hoverMenu)
      hoverMenu.find(type.orientationToggleId).addClass("active")

      for own groupName, groupProps of @groupTypes
        clickFunc = (groupProps) => => @changeGroup(groupProps, photoData)
        hoverMenu.find(groupProps.orientationToggleId).click(clickFunc(groupProps))

      hoverMenu.find(".moveUp").click => @moveUp newGroup
      hoverMenu.find(".moveDown").click => @moveDown newGroup

      hoverMenu.find(".hasText").click => @hideTextClick newGroup

      removePhotoLink = hoverMenu.find(".removePhoto")
      removePhotoLink.attr("href", removePhotoLink.data("href").replace("-1", photoData[0].id))

      newGroup.find(".imagePlace").append(@grabImage(type, photoData)).mouseenter( ->
        $(@).find(".imageHoverMenu").fadeIn("fast")
      ).mouseleave( ->
        $(@).find(".imageHoverMenu").fadeOut("fast")
      )

      newGroup.find(".textPlace > .time").on("click.editTime", -> storyHelper.editTime(@)).html(time)
      newGroup.find(".textPlace > .text").on("click.editText", -> storyHelper.editCaption(@)).html(text)

      if photoData.data("has-text") == true then @showText newGroup else @hideText newGroup

      newGroup

    changeGroup: (type, photoData) ->
      oldGroup = $("#group#{photoData[0].id}")
      return unless oldGroup[0]?

      group = @createGroup(type, photoData)

      if oldGroup.data("hideText") == "true" then @hideText group else @showText group

      group.find(".textPlace .text").html(oldGroup.find(".textPlace .text").html())
      group.find(".textPlace .time").html(oldGroup.find(".textPlace .time").html())

      oldGroup.fadeOut("fast")
      oldGroup.replaceWith group

      group.fadeIn("fast")
      @initializeGroup group
      @refreshFlowControl()

    addGroup: (type, photoData) ->
      return if $("#group#{photoData[0].id}")[0]

      group = @createGroup(type, photoData)

      @appendGroupToPosition group, photoData.data("order")
      @initializeGroup group

    appendGroupToPosition: (group, position) ->
      unless $("#story .storyGroup")[0]
        $("#story").append group
        return
      pos = @getRightPosition(parseInt(position)) - 1
      console.log "position: #{position} pos: #{pos}"
      if pos < 0
        $("#story").prepend group
      else
        $("#story .storyGroup:eq(#{pos})").after group

    getRightPosition: (position) ->
      positions = []
      positions.push $(storyGroup).data("order") for storyGroup in $("#story .storyGroup")
      positions.push position
      positions.sort()
      positions.indexOf position

    initializeGroup: (group) ->
      group.show()
      if group.data("orientation") == "center"
        #align text and time to image
        image = group.find(".imagePlace img")
        imageMarginLeft = (image.parent().width() - image.width()) / 2

        group.find(".imagePlace").css("margin-left", imageMarginLeft)
        group.find(".textPlace").css("margin-left", imageMarginLeft)

        dottedMarginLeft = group.find(".span0").parent().width() / 2

        group.find(".span0").css
          "height": 40
          "margin-left": dottedMarginLeft - 20

        group.find(".text").css(width: group.find(".imagePlace img").width())
      else
        group.find(".span0").css("height", group.find(".imagePlace img").height() + 40)

    grabImage: (type, photoData) ->
      return @grabSmallerImage(photoData) if type.name == "left" or type.name == "right"
      return @grabLargerImage(photoData) if type.name == "center"

    grabSmallerImage: (photoData) ->
      "<img src='#{photoData.data("medium-image")}' style='height:#{photoData.data("medium-height")}px; width:#{photoData.data("medium-width")}px'>"

    grabLargerImage: (photoData) ->
      "<img src='#{photoData.data("large-image")}' style='height:#{photoData.data("large-height")}px; width:#{photoData.data("large-width")}px'>"

    grabImageData: (index) -> $("#uploadedPhotoData > .photo").eq(index)

    eachPhoto: (callback) -> $("#uploadedPhotoData > .photo").each (index) -> callback index

    eachGroup: (callback) -> $(".storyGroup").each (index) -> callback(@, index)

    photoCount: -> $("#uploadedPhotoData > .photo").length

    editCaption: (textDiv) ->
      $textDiv = $(textDiv)
      $textDiv.html("<textarea class='textEdit'>#{$textDiv.html()}</textarea>")

      $textDiv.off("click.editText")
      $textDiv.addClass("onceEdited")

      $(document).on "click.documentEditText", (event) =>
        return if event and ($.contains(textDiv, event.target) or $(event.target).hasClass("text"))

        newCaption = $textDiv.find("textarea").val()
        $textDiv.text newCaption
        $.ajax
          type: "POST"
          cache: false
          url: $("#storyPhotoPath").val().replace(-1, $textDiv.closest(".storyGroup").data("id"))
          dataType: "script"
          data:
            "_method": "PUT"
            "story_photo[caption]": newCaption

        $(document).off("click.documentEditText")
        $textDiv.on("click.editText", => storyHelper.editCaption(textDiv))

    editTime: (timeDiv) ->
      $timeDiv = $(timeDiv)
      time = $.trim($timeDiv.html()).replace(/\s(am|pm)/, "")
      ampm = @extractAmPmSwitch $.trim($timeDiv.html())

      $timeDiv.html "<input class='timeEdit' value='#{time}'/>#{ampm}"
      $timeDiv.find(".timeEdit").inputmask({ "mask": "h:s"})[0].focus()

      $timeDiv.off("click.editTime")
      $(document).on "click.documentEditTime", (event) =>
        return if event and ($.contains(timeDiv, event.target) or $(event.target).hasClass("time"))

        $timeDiv.html($timeDiv.find(".timeEdit").val().replace(/_/, "") + @extractAmPm($timeDiv.find(".timeEditAmPm")[0]))
        $(document).off("click.documentEditTime")
        $timeDiv.on("click.editTime", => storyHelper.editTime(timeDiv))

    extractAmPm: (timeEditAmPm) ->
      if timeEditAmPm? then " " + $(timeEditAmPm).find("option:selected").val() else ""

    extractAmPmSwitch: (time) ->
      return "" if time.search(/(am|pm)/) == -1

      am = time.search(/pm/) == -1

      return "<select class='timeEditAmPm'><option value='am' #{'selected=selected' if am}>am</option><option value='pm' #{'selected=selected' if !am}>pm</option></select>"

    moveUp: (group) ->
      group.prev().before(group)
      @refreshFlowControl()

    moveDown: (group) ->
      group.next().after(group)
      @refreshFlowControl()

    hideTextClick: (group) ->
      if group.find(".hasText").hasClass("active") then @hideText(group) else @showText(group)

    isTextDefault: (text) -> $.trim(text) == $("#defaultStoryText").val().trim()

    hideText: (group) ->
      group.data("hideText", "true")
      group.css(float: 'left', clear: 'none')
      group.find(".textPlace").hide()
      group.find(".span0").css(border: "none", marginLeft: "10px", marginRight: "10px")
      group.find(".rightOrientation").hide()
      group.find(".leftOrientation").html(group.find(".leftOrientation").data("side"))
      group.find(".hasText").removeClass("active")

    showText: (group) ->
      group.data("hideText", "false")
      group.css(float: 'none', clear: 'both')
      group.find(".textPlace").show()
      group.find(".span0").css(border: "1px dotted gray", marginLeft: "20px", marginRight: "20px")
      group.find(".rightOrientation").show()
      group.find(".leftOrientation").html(group.find(".leftOrientation").data("left"))
      group.find(".hasText").addClass("active")

    refreshFlowControl: ->
      $(".moveUp, .moveDown").show()
      @eachGroup (group, index) =>
        $(group).find(".moveUp").hide() if index == 0
        $(group).find(".moveDown").hide() if index == (@photoCount() - 1)

    sortFileDatasByName: (fileDatas) ->
      fileDatas.sort (a, b) ->
        return -1 if a.files[0].name < b.files[0].name
        return 1 if a.files[0].name > b.files[0].name
        return 0

  window.storyHelper = new StoryHelper