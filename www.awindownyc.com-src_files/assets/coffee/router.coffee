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

      @after (req) -> aWindow.tracking.trackPage req.path

      @get '/', ->
        aWindow.updateView.update 'meta', 'root'

      @get '/index.html', ->
        aWindow.updateView.update 'meta', 'root'

      @get '/:titleNormalized', (req) ->
        aWindow.updateView.update 'meta', req.params.titleNormalized, if !req.queryString then false else
          title: req.params.title

      @get ':titleNormalized', (req) ->
        aWindow.updateView.update 'meta', req.params.titleNormalized, if !req.queryString then false else
          title: req.params.title

      @get '/:type/:titleNormalized', (req) ->
        aWindow.updateView.update req.params.type, req.params.titleNormalized

      @get '/item/:parentItem/:childItem', (req) ->
        aWindow.updateView.update 'sub-item', req.params.childItem

      @post '/contact', aWindow.contact.send

  _testHash = ->
    if location.hash
      Davis.location.assign new Davis.Request location.hash.replace /^#/, ''

  init: init