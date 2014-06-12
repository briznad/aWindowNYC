aWindow = aWindow or {}

aWindow.modelBuildr = do ->
  'use strict'

  init = (callback) ->
    getData callback

  getData = (callback) ->
    # ID of current CMS spreadsheet
    contentSpreadsheetID = '0AvY0yhzqHzgSdDRjV1UzcUxfQnRmSDNKcEhkUDlKeHc'

    # requesting data from Google
    request = $.ajax
      url:    'https://spreadsheets.google.com/feeds/list/' + contentSpreadsheetID + '/od6/public/values?alt=json-in-script'
      dataType: 'jsonp'

    # here's the data
    request.done (data) ->
      createCleanModel data, callback

    # uh-oh, something went wrong
    request.fail (data) ->
      aWindow.model = do aWindow.dummyData().model

      do callback

  createCleanModel = (data, callback) ->

    # add model object to aWindow
    aWindow.model = {}

    # sort each page type
    sortRawInput = (obj) ->

      # what type of object are we working with?
      key = obj.gsx$newpagetype.$t

      # process general info that all page types have
      tempCleanObj = processGeneral obj, key

      switch key
        when 'edition'
          # save the last processed edition as the current edition
          aWindow.model.settings = aWindow.model.settings or {}
          aWindow.model.settings.currentEdition = tempCleanObj.normalized

          tempCleanObj = _.extend tempCleanObj,
            additionalMedia:  if obj['gsx$' + key + '-additionalmedia']['$t'] is '' then false else obj['gsx$' + key + '-additionalmedia']['$t'].replace(/,\s/g, ',').split(',')
            items:          [] # create container array, to be populated in post-processing
            collaborators:  [] # create container array, to be populated in post-processing
            location:
              address:        obj['gsx$' + key + '-location-address']['$t']
              media:          if /^http/.test(obj['gsx$' + key + '-location-media']['$t']) then obj['gsx$' + key + '-location-media']['$t'] else '/assets/images/' + obj['gsx$' + key + '-location-media']['$t']
              description:    obj['gsx$' + key + '-location-description']['$t'].replace(/\n/g, '<br/>')
            contact:
              email:          obj['gsx$' + key + '-contact-email']['$t']
              phone:          obj['gsx$' + key + '-contact-phone']['$t']

        when 'collaborator'
          tempCleanObj = _.extend tempCleanObj,
            associatedWithEditions: [] # create container array, to be populated in post-processing
            items:                  [] # create container array, to be populated in post-processing

        when 'item'
          tempCleanObj = _.extend tempCleanObj,
            creator:            obj['gsx$' + key + '-creator']['$t']
            edition:            obj['gsx$' + key + '-edition']['$t']
            additionalMedia:    if obj['gsx$' + key + '-additionalmedia']['$t'] is '' then false else obj['gsx$' + key + '-additionalmedia']['$t'].replace(/,\s/g, ',').split(',')
            purchasePageMedia:
              source:             if /^http/.test(obj['gsx$' + key + '-purchasepage-media']['$t']) then obj['gsx$' + key + '-purchasepage-media']['$t'] else '/assets/images/' + obj['gsx$' + key + '-purchasepage-media']['$t']
              attribution:
                title:              if obj['gsx$' + key + '-purchasepage-mediaattributiontitle']['$t'] is '' then false else obj['gsx$' + key + '-purchasepage-mediaattributiontitle']['$t']
                link:               if obj['gsx$' + key + '-purchasepage-mediaattributionlink']['$t'] is '' then false else obj['gsx$' + key + '-purchasepage-mediaattributionlink']['$t']
            price:              obj['gsx$' + key + '-price']['$t']
            madeToOrder:        if obj['gsx$' + key + '-madetoorder']['$t'] is 'TRUE' then true else false
            soldOut:            if obj['gsx$' + key + '-soldout']['$t'] is 'TRUE' then true else false
            productionRun:      if obj['gsx$' + key + '-productionrun']['$t'] is '' then false else obj['gsx$' + key + '-productionrun']['$t']
            timeToShip:         if obj['gsx$' + key + '-timetoship']['$t'] is '' then false else obj['gsx$' + key + '-timetoship']['$t']
            'sub-items':        []

        when 'sub-item'
          tempCleanObj = _.extend tempCleanObj,
            parentItem:         obj['gsx$' + key + '-parentitem']['$t']
            purchasePageMedia:
              source:             if /^http/.test(obj['gsx$' + key + '-purchasepage-media']['$t']) then obj['gsx$' + key + '-purchasepage-media']['$t'] else '/assets/images/' + obj['gsx$' + key + '-purchasepage-media']['$t']
              attribution:
                title:              if obj['gsx$' + key + '-purchasepage-mediaattributiontitle']['$t'] is '' then false else obj['gsx$' + key + '-purchasepage-mediaattributiontitle']['$t']
                link:               if obj['gsx$' + key + '-purchasepage-mediaattributionlink']['$t'] is '' then false else obj['gsx$' + key + '-purchasepage-mediaattributionlink']['$t']
            price:              obj['gsx$' + key + '-price']['$t']
            madeToOrder:        if obj['gsx$' + key + '-madetoorder']['$t'] is 'TRUE' then true else false
            soldOut:            if obj['gsx$' + key + '-soldout']['$t'] is 'TRUE' then true else false
            productionRun:      if obj['gsx$' + key + '-productionrun']['$t'] is '' then false else obj['gsx$' + key + '-productionrun']['$t']
            timeToShip:         if obj['gsx$' + key + '-timetoship']['$t'] is '' then false else obj['gsx$' + key + '-timetoship']['$t']

      # make sure the correct container array exists in the model
      aWindow.model[key] = aWindow.model[key] or {}

      # after cleaning things up save to the model
      aWindow.model[key][tempCleanObj.normalized] = tempCleanObj

    processGeneral = (obj, key) ->
      # return the cleaned up bits
      processMedia
        type:         key
        title:        obj['gsx$' + key + '-title']['$t']
        normalized:   obj['gsx$' + key + '-normalized']['$t']
        description:  obj['gsx$' + key + '-description']['$t'].replace(/\n/g, '<br/>')
        media:
          source:       if obj['gsx$' + key + '-media']['$t'] is '' then false else obj['gsx$' + key + '-media']['$t']
          attribution:
            title:        if obj['gsx$' + key + '-mediaattributiontitle']['$t'] is '' then false else obj['gsx$' + key + '-mediaattributiontitle']['$t']
            link:         if obj['gsx$' + key + '-mediaattributionlink']['$t'] is '' then false else obj['gsx$' + key + '-mediaattributionlink']['$t']
      , obj

    #  process media
    processMedia = (obj, raw) ->
      # check for alternate media entry
      if !obj.media.source and raw['gsx$' + obj.type + '-media_2']
        obj.media.source = if raw['gsx$' + obj.type + '-media_2']['$t'] is '' then false else raw['gsx$' + obj.type + '-media_2']['$t']

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

    # after the initial model is created, do some additional processing
    postProcessing = (callback) ->
      # add the root/homepage stub
      aWindow.model.meta.root =
        type:         'meta'
        title:        'Root'
        normalized:   'root'
        description:  'This is the homepage.'

      # add the where stub
      aWindow.model.meta.where =
        type:         'meta'
        title:        'Where'
        normalized:   'where'
        description:  'Where are we now?'

      # add the editions list page by collating info on each edition
      aWindow.model.meta.editions =
        type:         'meta'
        title:        'Editions'
        normalized:   'editions'
        description:  'This is the Editions list.'
        displayOrder: _.keys aWindow.model.edition

      # add the collaborators list page by collating info on each collaborator
      aWindow.model.meta.collaborators =
        type:         'meta'
        title:        'Collaborators'
        normalized:   'collaborators'
        description:  'This is the Collaborators list.'
        displayOrder: do _.keys(aWindow.model.collaborator).sort

      # add the collaborators list page by collating info on each collaborator
      aWindow.model.meta.shop =
        type:         'meta'
        title:        'Shop'
        normalized:   'shop'
        description:  'This is the Items list.'
        displayOrder: _.keys aWindow.model.item

      # go through each sub-item to figure out which parent item it belongs to
      _.each aWindow.model['sub-item'], (value, key) ->
        aWindow.model.item[value.parentItem]['sub-items'].push key

      # go through each item to collate the following lists: items > editions, collaborators > editions, items > collaborator
      _.each aWindow.model.item, (value, key) ->
        # items > edition
        aWindow.model.edition[value.edition].items.push key

        # collaborators > edition
        aWindow.model.edition[value.edition].collaborators.push value.creator

        # items > collaborator
        aWindow.model.collaborator[value.creator].items.push key

        # support internal/external images for additional media
        if value.additionalMedia
          _.each value.additionalMedia, (img, key) ->
            value.additionalMedia[key] = '/assets/images/' + img if !/^http/.test img

        # sort sub-items
        do value['sub-items'].sort

      # sort collated lists
      _.each aWindow.model.edition, (value, key) ->
        do value.collaborators.sort
        do value.items.sort

      _.each aWindow.model.collaborator, (value, key) ->
        do value.items.sort

      do callback

    if data.feed.entry
      # go through each object in the raw input, clean it, and add it to the model object
      _.each data.feed.entry, sortRawInput

      # after building the model object spice up the data
      postProcessing ->
        do callback
    else
      aWindow.model =
        status: 'error'
        description: 'no "entry" object returned'
        data: data

      do callback

  init: init