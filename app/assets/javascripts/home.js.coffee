# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(->
  $.fn.showModal = (settings) ->
    this.find(".modal-header h3").html settings.header
    this.find(".modal-body").html settings.body
    this.find(".modal-footer .modal-okay").click(=>
      settings.okay() if settings.okay
      this.modal("hide")
    )
    this.find(".modal-footer .modal-cancel").click(=>
      settings.cancel() if settings.cancel
      this.modal("hide")
    )
    this.modal()
)