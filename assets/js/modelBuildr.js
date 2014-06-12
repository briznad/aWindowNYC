var aWindow;

aWindow = aWindow || {};

aWindow.modelBuildr = (function() {
  'use strict';
  var createCleanModel, getData, init;
  init = function(callback) {
    return getData(callback);
  };
  getData = function(callback) {
    var contentSpreadsheetID, request;
    contentSpreadsheetID = '0AvY0yhzqHzgSdDRjV1UzcUxfQnRmSDNKcEhkUDlKeHc';
    request = $.ajax({
      url: 'https://spreadsheets.google.com/feeds/list/' + contentSpreadsheetID + '/od6/public/values?alt=json-in-script',
      dataType: 'jsonp'
    });
    request.done(function(data) {
      return createCleanModel(data, callback);
    });
    return request.fail(function(data) {
      aWindow.model = aWindow.dummyData().model();
      return callback();
    });
  };
  createCleanModel = function(data, callback) {
    var postProcessing, processGeneral, processMedia, sortRawInput;
    aWindow.model = {};
    sortRawInput = function(obj) {
      var key, tempCleanObj;
      key = obj.gsx$newpagetype.$t;
      tempCleanObj = processGeneral(obj, key);
      switch (key) {
        case 'edition':
          aWindow.model.settings = aWindow.model.settings || {};
          aWindow.model.settings.currentEdition = tempCleanObj.normalized;
          tempCleanObj = _.extend(tempCleanObj, {
            additionalMedia: obj['gsx$' + key + '-additionalmedia']['$t'] === '' ? false : obj['gsx$' + key + '-additionalmedia']['$t'].replace(/,\s/g, ',').split(','),
            items: [],
            collaborators: [],
            location: {
              address: obj['gsx$' + key + '-location-address']['$t'],
              media: /^http/.test(obj['gsx$' + key + '-location-media']['$t']) ? obj['gsx$' + key + '-location-media']['$t'] : '/assets/images/' + obj['gsx$' + key + '-location-media']['$t'],
              description: obj['gsx$' + key + '-location-description']['$t'].replace(/\n/g, '<br/>')
            },
            contact: {
              email: obj['gsx$' + key + '-contact-email']['$t'],
              phone: obj['gsx$' + key + '-contact-phone']['$t']
            }
          });
          break;
        case 'collaborator':
          tempCleanObj = _.extend(tempCleanObj, {
            associatedWithEditions: [],
            items: []
          });
          break;
        case 'item':
          tempCleanObj = _.extend(tempCleanObj, {
            creator: obj['gsx$' + key + '-creator']['$t'],
            edition: obj['gsx$' + key + '-edition']['$t'],
            additionalMedia: obj['gsx$' + key + '-additionalmedia']['$t'] === '' ? false : obj['gsx$' + key + '-additionalmedia']['$t'].replace(/,\s/g, ',').split(','),
            purchasePageMedia: {
              source: /^http/.test(obj['gsx$' + key + '-purchasepage-media']['$t']) ? obj['gsx$' + key + '-purchasepage-media']['$t'] : '/assets/images/' + obj['gsx$' + key + '-purchasepage-media']['$t'],
              attribution: {
                title: obj['gsx$' + key + '-purchasepage-mediaattributiontitle']['$t'] === '' ? false : obj['gsx$' + key + '-purchasepage-mediaattributiontitle']['$t'],
                link: obj['gsx$' + key + '-purchasepage-mediaattributionlink']['$t'] === '' ? false : obj['gsx$' + key + '-purchasepage-mediaattributionlink']['$t']
              }
            },
            price: obj['gsx$' + key + '-price']['$t'],
            madeToOrder: obj['gsx$' + key + '-madetoorder']['$t'] === 'TRUE' ? true : false,
            soldOut: obj['gsx$' + key + '-soldout']['$t'] === 'TRUE' ? true : false,
            productionRun: obj['gsx$' + key + '-productionrun']['$t'] === '' ? false : obj['gsx$' + key + '-productionrun']['$t'],
            timeToShip: obj['gsx$' + key + '-timetoship']['$t'] === '' ? false : obj['gsx$' + key + '-timetoship']['$t'],
            'sub-items': []
          });
          break;
        case 'sub-item':
          tempCleanObj = _.extend(tempCleanObj, {
            parentItem: obj['gsx$' + key + '-parentitem']['$t'],
            purchasePageMedia: {
              source: /^http/.test(obj['gsx$' + key + '-purchasepage-media']['$t']) ? obj['gsx$' + key + '-purchasepage-media']['$t'] : '/assets/images/' + obj['gsx$' + key + '-purchasepage-media']['$t'],
              attribution: {
                title: obj['gsx$' + key + '-purchasepage-mediaattributiontitle']['$t'] === '' ? false : obj['gsx$' + key + '-purchasepage-mediaattributiontitle']['$t'],
                link: obj['gsx$' + key + '-purchasepage-mediaattributionlink']['$t'] === '' ? false : obj['gsx$' + key + '-purchasepage-mediaattributionlink']['$t']
              }
            },
            price: obj['gsx$' + key + '-price']['$t'],
            madeToOrder: obj['gsx$' + key + '-madetoorder']['$t'] === 'TRUE' ? true : false,
            soldOut: obj['gsx$' + key + '-soldout']['$t'] === 'TRUE' ? true : false,
            productionRun: obj['gsx$' + key + '-productionrun']['$t'] === '' ? false : obj['gsx$' + key + '-productionrun']['$t'],
            timeToShip: obj['gsx$' + key + '-timetoship']['$t'] === '' ? false : obj['gsx$' + key + '-timetoship']['$t']
          });
      }
      aWindow.model[key] = aWindow.model[key] || {};
      return aWindow.model[key][tempCleanObj.normalized] = tempCleanObj;
    };
    processGeneral = function(obj, key) {
      return processMedia({
        type: key,
        title: obj['gsx$' + key + '-title']['$t'],
        normalized: obj['gsx$' + key + '-normalized']['$t'],
        description: obj['gsx$' + key + '-description']['$t'].replace(/\n/g, '<br/>'),
        media: {
          source: obj['gsx$' + key + '-media']['$t'] === '' ? false : obj['gsx$' + key + '-media']['$t'],
          attribution: {
            title: obj['gsx$' + key + '-mediaattributiontitle']['$t'] === '' ? false : obj['gsx$' + key + '-mediaattributiontitle']['$t'],
            link: obj['gsx$' + key + '-mediaattributionlink']['$t'] === '' ? false : obj['gsx$' + key + '-mediaattributionlink']['$t']
          }
        }
      }, obj);
    };
    processMedia = function(obj, raw) {
      if (!obj.media.source && raw['gsx$' + obj.type + '-media_2']) {
        obj.media.source = raw['gsx$' + obj.type + '-media_2']['$t'] === '' ? false : raw['gsx$' + obj.type + '-media_2']['$t'];
      }
      if (obj.media.source) {
        obj.media.type = /^<iframe/.test(obj.media.source) ? 'video-embed' : /^http/.test(obj.media.source) ? 'external-image' : 'internal-image';
        if (obj.media.type === 'internal-image') {
          obj.media.source = '/assets/images/' + obj.media.source;
        }
      } else {
        obj.media.type = false;
      }
      return obj;
    };
    postProcessing = function(callback) {
      aWindow.model.meta.root = {
        type: 'meta',
        title: 'Root',
        normalized: 'root',
        description: 'This is the homepage.'
      };
      aWindow.model.meta.where = {
        type: 'meta',
        title: 'Where',
        normalized: 'where',
        description: 'Where are we now?'
      };
      aWindow.model.meta.editions = {
        type: 'meta',
        title: 'Editions',
        normalized: 'editions',
        description: 'This is the Editions list.',
        displayOrder: _.keys(aWindow.model.edition)
      };
      aWindow.model.meta.collaborators = {
        type: 'meta',
        title: 'Collaborators',
        normalized: 'collaborators',
        description: 'This is the Collaborators list.',
        displayOrder: _.keys(aWindow.model.collaborator).sort()
      };
      aWindow.model.meta.shop = {
        type: 'meta',
        title: 'Shop',
        normalized: 'shop',
        description: 'This is the Items list.',
        displayOrder: _.keys(aWindow.model.item)
      };
      _.each(aWindow.model['sub-item'], function(value, key) {
        return aWindow.model.item[value.parentItem]['sub-items'].push(key);
      });
      _.each(aWindow.model.item, function(value, key) {
        aWindow.model.edition[value.edition].items.push(key);
        aWindow.model.edition[value.edition].collaborators.push(value.creator);
        aWindow.model.collaborator[value.creator].items.push(key);
        if (value.additionalMedia) {
          _.each(value.additionalMedia, function(img, key) {
            if (!/^http/.test(img)) {
              return value.additionalMedia[key] = '/assets/images/' + img;
            }
          });
        }
        return value['sub-items'].sort();
      });
      _.each(aWindow.model.edition, function(value, key) {
        value.collaborators.sort();
        return value.items.sort();
      });
      _.each(aWindow.model.collaborator, function(value, key) {
        return value.items.sort();
      });
      return callback();
    };
    if (data.feed.entry) {
      _.each(data.feed.entry, sortRawInput);
      return postProcessing(function() {
        return callback();
      });
    } else {
      aWindow.model = {
        status: 'error',
        description: 'no "entry" object returned',
        data: data
      };
      return callback();
    }
  };
  return {
    init: init
  };
})();
