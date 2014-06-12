aWindow = aWindow or {}

aWindow.lightbox =  do ->
  'use strict'

  init = ->
    # register events
    aWindow.cache.$body.on 'click', 'a.primary-image:not(.sub-item), a.thumbnail-image:not(.sub-item)', _openLightbox
    aWindow.cache.$body.on 'click', '.lightbox-control', _controlLightbox
    aWindow.cache.$body.on 'click', '.lightbox-overlay', _closeLightbox

  _openLightbox = (e) ->
    do e.preventDefault
    do e.stopPropagation # important to prevent davisjs from intercepting the link

    $target = $ this
    $imgGroup = $ e.handleObj.selector

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