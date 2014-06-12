aWindow = aWindow or {}

aWindow.router = do ->
  'use strict'

  init = (callback = ->) ->
    do initRoutes
    do _testHash
    do callback

  initRoutes = ->
    routes = new Davis ->
      @configure (config) ->
        config.generateRequestOnPageLoad = true

      @before aWindow.updateView.beforeUpdate

      @get '/', ->
        aWindow.updateView.update 'meta', 'root'

      @get '/index.html', ->
      aWindow.updateView.update 'meta', 'root'

      @get '/:titleNormalized', (req) ->
        aWindow.updateView.update 'meta', req.params.titleNormalized

      @get ':titleNormalized', (req) ->
        aWindow.updateView.update 'meta', req.params.titleNormalized

      @get '/:type/:titleNormalized', (req) ->
        aWindow.updateView.update req.params.type, req.params.titleNormalized

      @get '/item/:titleNormalized/purchase', (req) ->
        aWindow.updateView.update 'item', req.params.titleNormalized, true

      @get '/item/:parentItem/:childItem/purchase', (req) ->
        aWindow.updateView.update 'sub-item', req.params.childItem, true

      @post '/contact', aWindow.contact.send

  _testHash = ->
    if location.hash
      Davis.location.assign new Davis.Request location.hash.replace /^#/, ''

  init: init