class WindowManager
  show: (header, content) ->
    modal = $("#modalWindowInit").html().clone()
    $(document.body).append(modal)