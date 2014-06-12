aWindow = aWindow or {}

aWindow.updateView = do ->
  'use strict'

  beforeUpdate = (request) ->
    # false if /jpg$|jpeg$|png$|gif$|bmp$/.test request.path

  update = (type, titleNormalized, purchasePage = false) ->
    # determine the current page object
    currentPage = aWindow.model[type][titleNormalized]

    # remove previous body classes
    do _removeBodyClasses

    # add current body classes
    _addBodyClasses type, titleNormalized, purchasePage

    # update model with current page info
    _updateCurrentPage type, titleNormalized, purchasePage

    # update page title and h1
    aWindow.cache.$title.add(aWindow.cache.$h1).text _computePageTitle type, currentPage.title, purchasePage

    # render new view
    aWindow.cache.$dynamicContainer.html aWindow.template.primaryTemplate
      data:                   aWindow.model
      currentType:            type
      currentTitleNormalized: titleNormalized
      currentPage:            currentPage
      currentEdition:         aWindow.model.settings.currentEdition
      purchasePage:           purchasePage

    # for item & edition pages, init scrollable media preview thumbnails
    if type is 'item' or type is 'edition' then do _initThumbnails

    else if titleNormalized is 'root'
      scene = document.getElementById 'parallax'
      parallax = new Parallax scene

    # for purchase pages, add cart events
    _cartEvents titleNormalized if purchasePage

  _updateBodyClasses = (method, classesArr) ->
    aWindow.cache.$body[method] classesArr.join ' '

  _removeBodyClasses = ->
    # remove previous body classes
    if aWindow.model.settings.currentPage
      _updateBodyClasses 'removeClass', [
        aWindow.model.settings.currentPage.type
        aWindow.model.settings.currentPage.titleNormalized
        'purchase'
      ]

  _addBodyClasses = (type, titleNormalized, purchasePage) ->
    # add current body classes
    _updateBodyClasses 'addClass', [
      type
      titleNormalized
      'purchase' if purchasePage
    ]

  _updateCurrentPage = (type, titleNormalized, purchasePage) ->
    aWindow.model.settings.currentPage = _.extend aWindow.model.settings.currentPage or {},
      type:             type
      titleNormalized:  titleNormalized
      purchasePage:     purchasePage

  _computePageTitle = (type, title, purchasePage) ->
    if title is 'Root' then '{a window]'
    else if type is 'edition'
      if purchasePage then '{a window] | ' + 'purchase edition' + title
      else '{a window] | ' + 'edition' + title
    else if purchasePage then '{a window] | ' + 'purchase ' + title
    else '{a window] | ' + title

  _cartEvents = (titleNormalized) ->
    aWindow.cache.$body
      .off('click.addToCart')
      .on 'click.addToCart', '.order-link', (e) ->
        do e.preventDefault

        Helium.cart.add titleNormalized
        do Helium.show

  _initThumbnails = ->
    $thumbContainer = $ '.additional-media'
    $thumbWrapper   = do $thumbContainer.parent
    $thumbnails     = $ '.thumbnail-image', $thumbContainer
    thumbsWidth     = 0

    $thumbnails.each ->
      thumbsWidth += $(this).outerWidth true

    $thumbContainer.width thumbsWidth if thumbsWidth > $thumbWrapper.innerWidth()

  beforeUpdate: beforeUpdate
  update:       update