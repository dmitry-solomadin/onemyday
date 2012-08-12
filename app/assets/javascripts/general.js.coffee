$(document).bind('ajaxSend', (e, request, options) ->
  $('[data-loading-text]').button('loading')
)

$(document).bind('ajaxComplete', (e, request, options) ->
  $('[data-loading-text]').button('complete')
)

$(->
  $("*[data-submitable]").each(-> $(@).click(-> $(@).closest("form").eq(0).submit()))
)
