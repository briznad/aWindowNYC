aWindow = aWindow or {}

aWindow.lightbox =  do ->
  'use strict'

  options =
    enabledElements: [
      '.primary-image:not(.sub-item)'
      '.thumbnail-image:not(.sub-item)'
    ]

  init = (opts = {}) ->
    _.extend options, opts

    # register events
    aWindow.cache.$body.on 'click', options.enabledElements.join(', '), _openLightbox

    aWindow.cache.$body.on 'click', '.lightbox-control', _controlLightbox
    aWindow.cache.$body.on 'click', '.lightbox-overlay', _closeLightbox

  _openLightbox = (e) ->
    do e.preventDefault
    do e.stopPropagation # important to prevent davisjs from intercepting the link

    $el = $ this

    console.log $el

    $target = if $el.is 'a' then $el else $el.closest 'a'

    aWindow.cache.$body.append aWindow.template.lightboxModule
      imgSource: $target.attr 'href'

  _controlLightbox = (e) ->
    do e.preventDefault
    do e.stopPropagation # important to prevent davisjs from intercepting the link

    aWindow.log 'control'

  _closeLightbox = (e) ->
    do e.preventDefault
    do $(e.currentTarget).remove if not $(e.target).is '.lightbox-container, .lightbox-img'

  init: init