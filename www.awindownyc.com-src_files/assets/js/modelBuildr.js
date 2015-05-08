var aWindow;

aWindow = aWindow || {};

aWindow.modelBuildr = (function() {
  'use strict';
  var init, _addMetaList, _addMetaPage, _cleanArrayify, _createCleanModel, _getData, _internalExternalImg, _lineBreakify, _postProcessing, _processAttribution, _processGeneral, _processMedia, _processSpecific, _slugify, _sortRawInput, _uppercasify;
  init = function(callback) {
    return _getData(callback);
  };
  _getData = function(callback) {
    var contentSpreadsheetID, request;
    contentSpreadsheetID = '0AmGcIEeEvbkWdFNTN3hEWDFMMU1heHo5c1NIZnlqV3c';
    request = $.ajax({
      url: 'https://spreadsheets.google.com/feeds/list/' + contentSpreadsheetID + '/od6/public/values?alt=json-in-script',
      dataType: 'jsonp'
    });
    request.done(function(data) {
      _createCleanModel(data, callback);
      return callback();
    });
    return request.fail(function(data) {
      aWindow.model = aWindow.tempData();
      return callback();
    });
  };
  _createCleanModel = function(data, callback) {
    aWindow.model = {};
    if (data.feed.entry) {
      aWindow.model.settings = {};
      _.each(data.feed.entry, _sortRawInput);
      return _postProcessing();
    } else {
      return aWindow.model = {
        status: 'error',
        description: 'no "entry" object returned',
        data: data
      };
    }
  };
  _sortRawInput = function(obj) {
    var key, tempCleanObj;
    key = obj.gsx$newpagetype.$t;
    aWindow.model[key] = aWindow.model[key] || {};
    tempCleanObj = _.extend(_processGeneral(obj, key), _processSpecific(obj, key));
    aWindow.model[key][tempCleanObj.normalized] = tempCleanObj;
    return _addMetaList(tempCleanObj);
  };
  _processGeneral = function(raw, key) {
    return _processMedia({
      type: key,
      title: raw['gsx$' + key + '-title']['$t'],
      normalized: _slugify(raw['gsx$' + key + '-normalized']['$t']),
      description: raw['gsx$' + key + '-description']['$t'] === '' ? false : _lineBreakify(raw['gsx$' + key + '-description']['$t']),
      media: {
        source: raw['gsx$' + key + '-media']['$t'] === '' ? false : raw['gsx$' + key + '-media']['$t'],
        attribution: _processAttribution(raw, key, false)
      }
    }, raw);
  };
  _processMedia = function(obj, raw) {
    if (!obj.media.source && raw['gsx$' + obj.type + '-media_2'] && raw['gsx$' + obj.type + '-media_2']['$t'] !== '') {
      obj.media.source = raw['gsx$' + obj.type + '-media_2']['$t'];
    }
    if (raw['gsx$' + obj.type + '-additionalmedia']) {
      obj.additionalMedia = raw['gsx$' + obj.type + '-additionalmedia']['$t'] === '' ? false : _cleanArrayify(raw['gsx$' + obj.type + '-additionalmedia']['$t']);
      if (obj.additionalMedia) {
        if (!obj.media.source) {
          obj.media.source = obj.additionalMedia.shift();
        }
        _.each(obj.additionalMedia, function(img, key) {
          return obj.additionalMedia[key] = _internalExternalImg(img);
        });
      }
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
  _processSpecific = function(obj, key) {
    var tempCleanObj;
    switch (key) {
      case 'edition':
        tempCleanObj = {
          items: [],
          collaborators: [],
          location: {
            address: obj['gsx$' + key + '-location-address']['$t'],
            media: _internalExternalImg(obj['gsx$' + key + '-location-media']['$t']),
            description: _lineBreakify(obj['gsx$' + key + '-location-description']['$t'])
          },
          contact: {
            email: obj['gsx$' + key + '-contact-email'] ? obj['gsx$' + key + '-contact-email']['$t'] : false,
            phone: obj['gsx$' + key + '-contact-phone'] ? obj['gsx$' + key + '-contact-phone']['$t'] : false
          }
        };
        break;
      case 'collaborator':
        tempCleanObj = {
          associatedWithEditions: [],
          items: []
        };
        break;
      case 'item':
        tempCleanObj = {
          creator: _slugify(obj['gsx$' + key + '-creator']['$t']),
          edition: _slugify(obj['gsx$' + key + '-edition']['$t']),
          purchasePageMedia: {
            source: _internalExternalImg(obj['gsx$' + key + '-purchasepage-media']['$t']),
            attribution: _processAttribution(obj, key)
          },
          price: obj['gsx$' + key + '-price']['$t'],
          purchaseDetails: obj['gsx$' + key + '-purchasedetails']['$t'] === '' ? false : _lineBreakify(obj['gsx$' + key + '-purchasedetails']['$t']),
          madeToOrder: obj['gsx$' + key + '-madetoorder']['$t'] === 'TRUE' ? true : false,
          soldOut: obj['gsx$' + key + '-soldout']['$t'] === 'TRUE' ? true : false,
          productionRun: obj['gsx$' + key + '-productionrun']['$t'] === '' ? false : obj['gsx$' + key + '-productionrun']['$t'],
          timeToShip: obj['gsx$' + key + '-timetoship']['$t'] === '' ? false : obj['gsx$' + key + '-timetoship']['$t'],
          'sub-items': []
        };
        break;
      case 'sub-item':
        tempCleanObj = {
          parentItem: _slugify(obj['gsx$' + key + '-parentitem']['$t']),
          purchasePageMedia: {
            source: _internalExternalImg(obj['gsx$' + key + '-purchasepage-media']['$t']),
            attribution: _processAttribution(obj, key)
          },
          price: obj['gsx$' + key + '-price']['$t'],
          purchaseDetails: obj['gsx$' + key + '-purchasedetails']['$t'] === '' ? false : _lineBreakify(obj['gsx$' + key + '-purchasedetails']['$t']),
          madeToOrder: obj['gsx$' + key + '-madetoorder']['$t'] === 'TRUE' ? true : false,
          soldOut: obj['gsx$' + key + '-soldout']['$t'] === 'TRUE' ? true : false,
          productionRun: obj['gsx$' + key + '-productionrun']['$t'] === '' ? false : obj['gsx$' + key + '-productionrun']['$t'],
          timeToShip: obj['gsx$' + key + '-timetoship']['$t'] === '' ? false : obj['gsx$' + key + '-timetoship']['$t']
        };
    }
    return tempCleanObj;
  };
  _processAttribution = function(raw, key, purchasePage) {
    var tempLink, tempTitle;
    if (purchasePage == null) {
      purchasePage = true;
    }
    tempTitle = raw['gsx$' + key + (purchasePage ? '-purchasepage' : '') + '-mediaattributiontitle']['$t'];
    tempLink = raw['gsx$' + key + (purchasePage ? '-purchasepage' : '') + '-mediaattributionlink']['$t'];
    return {
      title: tempTitle === '' ? false : tempTitle,
      link: tempLink === '' ? false : /^http/.test(tempLink) || /^\/\//.test(tempLink) ? tempLink : '//' + tempLink
    };
  };
  _addMetaList = function(cleanObj) {
    var objPlural;
    aWindow.model.meta = aWindow.model.meta || {};
    objPlural = cleanObj.type + 's';
    if (['meta', 'sub-item'].indexOf(cleanObj.type) !== -1 || typeof aWindow.model.meta[objPlural] === 'object') {
      return false;
    }
    return _addMetaPage(objPlural, 'This is the ' + _uppercasify(objPlural) + ' list.', {
      metaListType: cleanObj.type
    });
  };
  _addMetaPage = function(slug, description, additionalFields) {
    var properSlug;
    if (additionalFields == null) {
      additionalFields = {};
    }
    properSlug = _uppercasify(slug);
    if (description == null) {
      description = 'This is the ' + properSlug + ' page.';
    }
    return aWindow.model.meta[slug] = _.extend({
      type: 'meta',
      normalized: slug,
      title: properSlug,
      description: description
    }, additionalFields);
  };
  _postProcessing = function() {
    _addMetaPage('root', 'This is the homepage.');
    _addMetaPage('terms', 'Terms & Conditions');
    _addMetaPage('contact', 'Contact Us');
    _addMetaPage('edition-one-parallax', null, {
      title: 'Edition One Parallax',
      description: 'This is the Edition One Parallax page.'
    });
    _addMetaPage('where', 'Where are we now?');
    _addMetaPage('shop', 'This is the Items list.', {
      metaListType: 'item',
      displayOrder: []
    });
    _.each(aWindow.model.meta, function(value, key) {
      if (value.metaListType && !value.displayOrder) {
        return value.displayOrder = _.keys(aWindow.model[value.metaListType]).sort();
      }
    });
    _.each(aWindow.model['sub-item'], function(value, key) {
      aWindow.model.item[value.parentItem]['sub-items'].push(key);
      value.edition = aWindow.model.item[value.parentItem].edition;
      value.creator = aWindow.model.item[value.parentItem].creator;
      return aWindow.model.collaborator[value.creator].items.push(key);
    });
    _.each(aWindow.model.item, function(value, key) {
      var priceRange;
      value.galleryItem = /^gallery/.test(key) ? true : false;
      aWindow.model.edition[value.edition].items.push(key);
      if (value.creator) {
        aWindow.model.edition[value.edition].collaborators.push(value.creator);
      }
      if (value['sub-items'].length) {
        value['sub-items'].sort();
        priceRange = [];
        _.each(value['sub-items'], function(subItem, key) {
          return priceRange.push(parseInt(aWindow.model['sub-item'][subItem].price.replace('$', '')));
        });
        priceRange.sort();
        value.price = '$' + priceRange.shift() + ' - $' + priceRange.pop();
        if (!value.purchasePageMedia.source) {
          value.purchasePageMedia = aWindow.model['sub-item'][value['sub-items'][0]].purchasePageMedia;
        }
        return aWindow.model.meta.shop.displayOrder = aWindow.model.meta.shop.displayOrder.concat(value['sub-items']);
      } else {
        aWindow.model.meta.shop.displayOrder.push(key);
        if (value.creator) {
          return aWindow.model.collaborator[value.creator].items.push(key);
        }
      }
    });
    aWindow.model.meta.shop.displayOrder.sort();
    _.each(aWindow.model.edition, function(value, key) {
      aWindow.model.settings.currentEdition = key;
      value.collaborators.sort();
      value.items.sort();
      return value.collaborators = _.uniq(value.collaborators, true);
    });
    return _.each(aWindow.model.collaborator, function(value, key) {
      return value.items.sort();
    });
  };
  _slugify = function(rawInput) {
    return rawInput.replace(/^\s|\s$/, '').replace(/\s/g, '-');
  };
  _uppercasify = function(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  };
  _lineBreakify = function(rawInput) {
    return rawInput.replace(/\n/g, '<br/>');
  };
  _cleanArrayify = function(rawInput) {
    return rawInput.replace(/,\s/g, ',').split(',');
  };
  _internalExternalImg = function(imgLocation) {
    if (imgLocation === '') {
      return false;
    } else if (/^http/.test(imgLocation)) {
      return imgLocation;
    } else {
      return '/assets/images/' + imgLocation;
    }
  };
  return {
    init: init
  };
})();
