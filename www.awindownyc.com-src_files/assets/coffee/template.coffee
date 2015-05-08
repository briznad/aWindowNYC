aWindow = aWindow or {}

aWindow.template = do ->
  'use strict'

  init = (callback) ->
    request = $.ajax
      url: '/assets/templates/templates.html',
      dataType: 'html',

    request.done (data) ->
      _processTemplates data, callback

    # uh-oh, something went wrong
    request.fail (data) ->
      _processTemplates do aWindow.dummyData().template, callback

  _processTemplates = (response, callback) ->
    $templates = $(response).filter 'script[type="text/html"]'

    $templates.each ->
      aWindow.template[$(this).attr 'id'] = _.template $(this).html()

    do callback

  init : init