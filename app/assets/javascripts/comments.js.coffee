# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class App.Comments

  constructor: ->
    return unless $("#commentsContainer")[0]

    @form = $("#commentsContainer").find("form")
    @textarea = $("#addCommentTextarea")
    @submit = $("#addCommentSubmit")

    @textarea.keyup => @toggleSendButton()

  edit: (link) ->
    comment = $(link).closest('.comment')
    $("#addCommentTextarea").val(comment.find(".text").html())

    @form.prepend($("<input type='hidden' name='comment[id]' value='#{comment.data('comment-id')}'/>"))
    @form.data("previous-action", @form.attr("action"))
    @form.attr("action", comment.find(".edit-comment-action").val())
    @form.attr("method", "PUT")

  revertEdit: ->
    @form.attr("action", @form.data("previous-action"))
    @form.attr("method", "POST")
    @form.removeAttr("data-previous-action")
    @form.find("input[name='commentId']").remove()
    $("#addCommentTextarea").val("")

    @toggleSendButton()

  toggleSendButton: ->
    if $.trim(@textarea.val()).length == 0
      @submit.attr("disabled", "disabled")
    else
      @submit.removeAttr("disabled")

$ -> App.comments = new App.Comments

