aWindow = aWindow or {}

aWindow.updateView = do ->
  'use strict'

  beforeUpdate = (request) ->
    # false if /jpg$|jpeg$|png$|gif$|bmp$/.test request.path

  update = (type, titleNormalized, contactData = false) ->
    # determine the current page object
    currentPage = aWindow.model[type][titleNormalized]

    # check meta redirects
    # if redirect is necessary, shut down current loading view
    if type is 'meta' and _metaRedirects currentPage then return false

    # remove previous body classes
    do _removeBodyClasses

    # add current body classes
    _addBodyClasses type, titleNormalized

    # update model with current page info
    _updateCurrentPage type, titleNormalized

    # update page title and h1
    aWindow.cache.$title.add(aWindow.cache.$h1).text _computePageTitle type, currentPage.title

    # render new view
    aWindow.cache.$dynamicContainer.html aWindow.template.primaryTemplate
      data:                   aWindow.model
      currentType:            type
      currentTitleNormalized: titleNormalized
      currentPage:            currentPage
      currentEdition:         aWindow.model.settings.currentEdition
      contactData:            contactData

    # initialize events necessary for each page
    _initEvents type, titleNormalized

  _metaRedirects = (currentPage) ->
    # if this is a meta list page, we may need to redirect
    if currentPage.metaListType
      # if there are no members of the display order list, redirect to the homepage
      if !currentPage.displayOrder.length
        Davis.location.assign new Davis.Request '/'

        return true

      # if there is only 1 member of the display order list, redirect to that page
      else if currentPage.displayOrder.length is 1
        Davis.location.assign new Davis.Request '/' + currentPage.metaListType + '/' + currentPage.displayOrder[0]

        return true

    return false

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

  _addBodyClasses = (type, titleNormalized) ->
    # add current body classes
    _updateBodyClasses 'addClass', [
      type
      titleNormalized
    ]

  _updateCurrentPage = (type, titleNormalized) ->
    aWindow.model.settings.currentPage = _.extend aWindow.model.settings.currentPage or {},
      type:             type
      titleNormalized:  titleNormalized

  _computePageTitle = (type, title) ->
    title = do title.toLowerCase

    if title is 'root'
      'a w i n d o w'
    else if type is 'edition'
      'a w i n d o w | ' + 'edition ' + title
    else
      'a w i n d o w | ' + title

  # basic router to load event registration for each page
  _initEvents = (type, titleNormalized) ->
    currentPage = aWindow.model[type][titleNormalized]

    if titleNormalized is 'root'
      # init parallax & hover
      # do _initParallax

    else if titleNormalized is 'edition-one-parallax'
      # init parallax & hover
      do _initParallax

    else if type is 'item' or type is 'sub-item'
      # add cart events
      _cartEvents titleNormalized

      _initLearnMore currentPage

      _initChooseDesign type, currentPage, titleNormalized if type is 'sub-item' or currentPage['sub-items'].length

      # init thumbnails
      # do _initThumbnails

    # for edition pages, init scrollable media preview thumbnails
    else if ['edition', 'project', 'event'].indexOf(type) isnt -1 then do _initThumbnails

  # init parallax & hover
  _initParallax = ->
    scene = document.getElementById 'parallax'
    parallax = new Parallax scene

    $scene = $(scene)

    toggleClass = (item) ->
      $scene.toggleClass $(item).attr('class').split(' ')[2] + '-hover'

    $scene.find('.link-layer').on
      mouseenter: -> toggleClass this
      mouseleave: -> toggleClass this

  _initLearnMore = (currentPage) ->
    # only learn more about parent items
    currentPage = aWindow.model.item[currentPage.parentItem] if currentPage.parentItem

    aWindow.cache.$body
      .off('click.learnMore')
      .on 'click.learnMore', '.learn-more-link', (e) ->
        do e.preventDefault

        aWindow.modal.open aWindow.template.learnMoreModule(
          currentPage : currentPage
          attribution : currentPage.media.attribution
        ),
          displayDuration   : false
          additionalClasses : ['learn-more-modal']

  _initChooseDesign = (type, currentPage, titleNormalized) ->
    currentSubItem = false

    # if we're on a sub-item page, refer to parent item
    if type is 'sub-item'
      currentSubItem = titleNormalized
      titleNormalized = currentPage.parentItem
      currentPage = aWindow.model.item[titleNormalized]

    aWindow.cache.$body
      .off('click.chooseDesign')
      .on 'click.chooseDesign', '.choose-design-btn, .choose-design-link', (e) ->
        do e.preventDefault

        aWindow.modal.open aWindow.template.chooseDesignModule(
          data                    : aWindow.model
          currentPage             : currentPage
          currentSubItem          : currentSubItem
          currentTitleNormalized  : titleNormalized
        ),
          displayDuration   : false
          additionalClasses : ['choose-design-modal']

        aWindow.cache.$body
          .off('click.destroyChooseDesignModal')
          .on 'click.destroyChooseDesignModal', '.sub-item-link', ->
            do $(this).closest('.choose-design-modal').remove

  _cartEvents = (titleNormalized) ->
    aWindow.cache.$body
      .off('click.addToCart')
      .on 'click.addToCart', '.order-link', (e) ->
        do e.preventDefault

        Helium.cart.add titleNormalized
        do Helium.show

        do aWindow.tracking.addToCart

        do aWindow.tracking.heliumCartEvents

  _initThumbnails = ->
    $thumbContainer = $ '.additional-media'
    $thumbWrapper   = do $thumbContainer.parent
    $thumbnails     = $ '.thumbnail-image', $thumbContainer
    thumbsWidth     = 0

    $thumbnails.each ->
      thumbsWidth += $(this).outerWidth true

    $thumbContainer.width thumbsWidth if thumbsWidth > $thumbWrapper.innerWidth()

  beforeUpdate  : beforeUpdate
  update        : update