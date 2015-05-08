aWindow = aWindow or {}

aWindow.modelBuildr = do ->
  'use strict'

  init = (callback) ->
    _getData callback

  _getData = (callback) ->
    # ID of current CMS spreadsheet
    contentSpreadsheetID = '0AmGcIEeEvbkWdFNTN3hEWDFMMU1heHo5c1NIZnlqV3c'

    # requesting data from Google
    request = $.ajax
      url:    'https://spreadsheets.google.com/feeds/list/' + contentSpreadsheetID + '/od6/public/values?alt=json-in-script'
      dataType: 'jsonp'

    # here's the data
    request.done (data) ->
      _createCleanModel data, callback

      # all done
      do callback

    # uh-oh, something went wrong
    request.fail (data) ->
      aWindow.model = do aWindow.tempData

      # all done
      do callback

  _createCleanModel = (data, callback) ->

    # add model object to aWindow
    aWindow.model = {}

    if data.feed.entry
      # create settings object
      aWindow.model.settings = {}

      # go through each object in the raw input, clean it, and add it to the model object
      _.each data.feed.entry, _sortRawInput

      # after building the model object spice up the data
      do _postProcessing
    else
      aWindow.model =
        status: 'error'
        description: 'no "entry" object returned'
        data: data

  # sort each page type
  _sortRawInput = (obj) ->
    # what type of object are we working with?
    key = obj.gsx$newpagetype.$t

    # make sure the correct container array exists in the model
    aWindow.model[key] = aWindow.model[key] or {}

    # temp data
    tempCleanObj = _.extend _processGeneral(obj, key), _processSpecific(obj, key)

    # after cleaning things up save to the model
    aWindow.model[key][tempCleanObj.normalized] = tempCleanObj

    # add meta list page
    _addMetaList tempCleanObj

  # general info added to each info type
  _processGeneral = (raw, key) ->
    # return the cleaned up bits
    _processMedia
      type:         key
      title:        raw['gsx$' + key + '-title']['$t']
      normalized:   _slugify raw['gsx$' + key + '-normalized']['$t']
      description:  if raw['gsx$' + key + '-description']['$t'] is '' then false else _lineBreakify raw['gsx$' + key + '-description']['$t']
      media:
        source:       if raw['gsx$' + key + '-media']['$t'] is '' then false else raw['gsx$' + key + '-media']['$t']
        attribution:  _processAttribution raw, key, false
    , raw

  # process media
  _processMedia = (obj, raw) ->
    # check for alternate media entry
    if !obj.media.source and raw['gsx$' + obj.type + '-media_2'] and raw['gsx$' + obj.type + '-media_2']['$t'] isnt ''
      obj.media.source = raw['gsx$' + obj.type + '-media_2']['$t']

    # process additional media
    if raw['gsx$' + obj.type + '-additionalmedia']
      obj.additionalMedia = if raw['gsx$' + obj.type + '-additionalmedia']['$t'] is '' then false else _cleanArrayify raw['gsx$' + obj.type + '-additionalmedia']['$t']

      if obj.additionalMedia
        # make sure a main media is set
        if !obj.media.source
          obj.media.source = do obj.additionalMedia.shift

        # support internal/external images for additional media
        _.each obj.additionalMedia, (img, key) ->
          obj.additionalMedia[key] = _internalExternalImg img

    if obj.media.source
      # figure out the type of media
      obj.media.type = if /^<iframe/.test(obj.media.source) then 'video-embed' else if /^http/.test(obj.media.source) then 'external-image' else 'internal-image'

      # prepend relative image path for internal images
      if obj.media.type is 'internal-image'
        obj.media.source = '/assets/images/' + obj.media.source

    else
      obj.media.type = false

    # return processed obj
    obj

  # custom info needed by specific types
  _processSpecific = (obj, key) ->
    switch key
      when 'edition'
        tempCleanObj =
          items:          [] # create container array, to be populated in post-processing
          collaborators:  [] # create container array, to be populated in post-processing
          location:
            address:        obj['gsx$' + key + '-location-address']['$t']
            media:          _internalExternalImg obj['gsx$' + key + '-location-media']['$t']
            description:    _lineBreakify obj['gsx$' + key + '-location-description']['$t']
          contact:
            email:          if obj['gsx$' + key + '-contact-email'] then obj['gsx$' + key + '-contact-email']['$t'] else false
            phone:          if obj['gsx$' + key + '-contact-phone'] then obj['gsx$' + key + '-contact-phone']['$t'] else false

      when 'collaborator'
        tempCleanObj =
          associatedWithEditions: [] # create container array, to be populated in post-processing
          items:                  [] # create container array, to be populated in post-processing

      when 'item'
        tempCleanObj =
          creator:            _slugify obj['gsx$' + key + '-creator']['$t']
          edition:            _slugify obj['gsx$' + key + '-edition']['$t']
          purchasePageMedia:
            source:             _internalExternalImg obj['gsx$' + key + '-purchasepage-media']['$t']
            attribution:        _processAttribution obj, key
          price:              obj['gsx$' + key + '-price']['$t']
          purchaseDetails:    if obj['gsx$' + key + '-purchasedetails']['$t'] is '' then false else _lineBreakify obj['gsx$' + key + '-purchasedetails']['$t']
          madeToOrder:        if obj['gsx$' + key + '-madetoorder']['$t'] is 'TRUE' then true else false
          soldOut:            if obj['gsx$' + key + '-soldout']['$t'] is 'TRUE' then true else false
          productionRun:      if obj['gsx$' + key + '-productionrun']['$t'] is '' then false else obj['gsx$' + key + '-productionrun']['$t']
          timeToShip:         if obj['gsx$' + key + '-timetoship']['$t'] is '' then false else obj['gsx$' + key + '-timetoship']['$t']
          'sub-items':        []

      when 'sub-item'
        tempCleanObj =
          parentItem:         _slugify obj['gsx$' + key + '-parentitem']['$t']
          purchasePageMedia:
            source:             _internalExternalImg obj['gsx$' + key + '-purchasepage-media']['$t']
            attribution:        _processAttribution obj, key
          price:              obj['gsx$' + key + '-price']['$t']
          purchaseDetails:    if obj['gsx$' + key + '-purchasedetails']['$t'] is '' then false else _lineBreakify obj['gsx$' + key + '-purchasedetails']['$t']
          madeToOrder:        if obj['gsx$' + key + '-madetoorder']['$t'] is 'TRUE' then true else false
          soldOut:            if obj['gsx$' + key + '-soldout']['$t'] is 'TRUE' then true else false
          productionRun:      if obj['gsx$' + key + '-productionrun']['$t'] is '' then false else obj['gsx$' + key + '-productionrun']['$t']
          timeToShip:         if obj['gsx$' + key + '-timetoship']['$t'] is '' then false else obj['gsx$' + key + '-timetoship']['$t']

    # return the cleaned up bits
    tempCleanObj

  # process media attribution
  _processAttribution = (raw, key, purchasePage = true) ->
    tempTitle = raw['gsx$' + key + (if purchasePage then '-purchasepage' else '') + '-mediaattributiontitle']['$t']
    tempLink = raw['gsx$' + key + (if purchasePage then '-purchasepage' else '') + '-mediaattributionlink']['$t']

    title:  if tempTitle is '' then false else tempTitle
    link:   if tempLink is '' then false else if /^http/.test(tempLink) or /^\/\//.test(tempLink) then tempLink else '//' + tempLink

  # add meta list page for most objects
  _addMetaList = (cleanObj) ->
    # ensure meta exists
    aWindow.model.meta = aWindow.model.meta or {}

    objPlural = cleanObj.type + 's'

    # don't create meta list if:
    #   type is "meta" or "sub-item"
    #   meta list already exists
    if ['meta', 'sub-item'].indexOf(cleanObj.type) isnt -1 or typeof aWindow.model.meta[objPlural] is 'object' then return false

    _addMetaPage objPlural, 'This is the ' + _uppercasify(objPlural) + ' list.',
      metaListType: cleanObj.type

  # add meta page
  _addMetaPage = (slug, description, additionalFields = {}) ->
    properSlug = _uppercasify slug

    if !description?
      description = 'This is the ' + properSlug + ' page.'

    aWindow.model.meta[slug] = _.extend
      type:         'meta'
      normalized:   slug
      title:        properSlug
      description:  description
    , additionalFields

  # after the initial model is created, do some additional processing
  _postProcessing = ->
    # work on meta
    # add the root/homepage stub
    _addMetaPage 'root', 'This is the homepage.'

    # add the terms stub
    _addMetaPage 'terms', 'Terms & Conditions'

    # add the contact stub
    _addMetaPage 'contact', 'Contact Us'

    # add the contact stub
    _addMetaPage 'edition-one-parallax', null,
      title:        'Edition One Parallax'
      description:  'This is the Edition One Parallax page.'

    # add the where stub
    _addMetaPage 'where', 'Where are we now?'

    # add the shop list
    _addMetaPage 'shop', 'This is the Items list.',
      metaListType: 'item'
      displayOrder: []

    _.each aWindow.model.meta, (value, key) ->
      # if this is a list page and displayOrder has yet to be defined
      if value.metaListType and !value.displayOrder
        value.displayOrder = do _.keys(aWindow.model[value.metaListType]).sort

    # work on sub-items
    _.each aWindow.model['sub-item'], (value, key) ->
      # figure out which parent item it belongs to
      aWindow.model.item[value.parentItem]['sub-items'].push key

      # figure out this sub-item's edition
      value.edition = aWindow.model.item[value.parentItem].edition

      # grab creator value from parent item
      value.creator = aWindow.model.item[value.parentItem].creator

      # add sub-item to creator's list of items
      aWindow.model.collaborator[value.creator].items.push key

    # work on items
    _.each aWindow.model.item, (value, key) ->
      # determine if this is the entire gallery item
      value.galleryItem = if /^gallery/.test(key) then true else false

      # collate the following lists: items > editions, items > collaborator, collaborators > editions
      aWindow.model.edition[value.edition].items.push key

      if value.creator
        # collaborators > edition
        aWindow.model.edition[value.edition].collaborators.push value.creator

      # if this item has sub-items, do more stuff
      if value['sub-items'].length
        # sort sub-items
        do value['sub-items'].sort

        # iterate through sub-item prices to determine price range
        priceRange = []

        _.each value['sub-items'], (subItem, key) ->
          priceRange.push parseInt aWindow.model['sub-item'][subItem].price.replace '$', ''

        do priceRange.sort

        value.price = '$' + do priceRange.shift + ' - $' + do priceRange.pop

        # if unset, assign purchase page media based on 1st sub-item
        unless value.purchasePageMedia.source
          value.purchasePageMedia = aWindow.model['sub-item'][value['sub-items'][0]].purchasePageMedia

        # collate meta shop page sub-item list
        aWindow.model.meta.shop.displayOrder = aWindow.model.meta.shop.displayOrder.concat value['sub-items']

      else
        # collate meta shop page item list
        aWindow.model.meta.shop.displayOrder.push key

        if value.creator
          # items > collaborator
          aWindow.model.collaborator[value.creator].items.push key

    # sort meta shop page item / sub-item list
    do aWindow.model.meta.shop.displayOrder.sort

    # work on the editions
    _.each aWindow.model.edition, (value, key) ->
      # save the last processed edition as the current edition
      aWindow.model.settings.currentEdition = key

      # sort collated lists
      do value.collaborators.sort
      do value.items.sort

      # prevent duplicate collaborators
      value.collaborators = _.uniq value.collaborators, true

    # work on the collaborators
    _.each aWindow.model.collaborator, (value, key) ->
      # sort collated lists
      do value.items.sort

  # helpers
  _slugify = (rawInput) ->
    rawInput.replace(/^\s|\s$/, '').replace(/\s/g, '-')

  _uppercasify = (string) ->
    string.charAt(0).toUpperCase() + string.slice(1)

  _lineBreakify = (rawInput) ->
    rawInput.replace(/\n/g, '<br/>')

  _cleanArrayify = (rawInput) ->
    rawInput.replace(/,\s/g, ',').split(',')

  _internalExternalImg = (imgLocation) ->
    if imgLocation is ''
      false
    else if /^http/.test(imgLocation)
      imgLocation
    else
      '/assets/images/' + imgLocation

  init: init