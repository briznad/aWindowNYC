var aWindow;

aWindow = aWindow || {};

aWindow.updateView = (function() {
  'use strict';
  var beforeUpdate, update, _addBodyClasses, _cartEvents, _computePageTitle, _initThumbnails, _removeBodyClasses, _updateBodyClasses, _updateCurrentPage;
  beforeUpdate = function(request) {};
  update = function(type, titleNormalized, purchasePage) {
    var currentPage, parallax, scene;
    if (purchasePage == null) {
      purchasePage = false;
    }
    currentPage = aWindow.model[type][titleNormalized];
    _removeBodyClasses();
    _addBodyClasses(type, titleNormalized, purchasePage);
    _updateCurrentPage(type, titleNormalized, purchasePage);
    aWindow.cache.$title.add(aWindow.cache.$h1).text(_computePageTitle(type, currentPage.title, purchasePage));
    aWindow.cache.$dynamicContainer.html(aWindow.template.primaryTemplate({
      data: aWindow.model,
      currentType: type,
      currentTitleNormalized: titleNormalized,
      currentPage: currentPage,
      currentEdition: aWindow.model.settings.currentEdition,
      purchasePage: purchasePage
    }));
    if (type === 'item' || type === 'edition') {
      _initThumbnails();
    } else if (titleNormalized === 'root') {
      scene = document.getElementById('parallax');
      parallax = new Parallax(scene);
    }
    if (purchasePage) {
      return _cartEvents(titleNormalized);
    }
  };
  _updateBodyClasses = function(method, classesArr) {
    return aWindow.cache.$body[method](classesArr.join(' '));
  };
  _removeBodyClasses = function() {
    if (aWindow.model.settings.currentPage) {
      return _updateBodyClasses('removeClass', [aWindow.model.settings.currentPage.type, aWindow.model.settings.currentPage.titleNormalized, 'purchase']);
    }
  };
  _addBodyClasses = function(type, titleNormalized, purchasePage) {
    return _updateBodyClasses('addClass', [type, titleNormalized, purchasePage ? 'purchase' : void 0]);
  };
  _updateCurrentPage = function(type, titleNormalized, purchasePage) {
    return aWindow.model.settings.currentPage = _.extend(aWindow.model.settings.currentPage || {}, {
      type: type,
      titleNormalized: titleNormalized,
      purchasePage: purchasePage
    });
  };
  _computePageTitle = function(type, title, purchasePage) {
    if (title === 'Root') {
      return '{a window]';
    } else if (type === 'edition') {
      if (purchasePage) {
        return '{a window] | ' + 'purchase edition' + title;
      } else {
        return '{a window] | ' + 'edition' + title;
      }
    } else if (purchasePage) {
      return '{a window] | ' + 'purchase ' + title;
    } else {
      return '{a window] | ' + title;
    }
  };
  _cartEvents = function(titleNormalized) {
    return aWindow.cache.$body.off('click.addToCart').on('click.addToCart', '.order-link', function(e) {
      e.preventDefault();
      Helium.cart.add(titleNormalized);
      return Helium.show();
    });
  };
  _initThumbnails = function() {
    var $thumbContainer, $thumbWrapper, $thumbnails, thumbsWidth;
    $thumbContainer = $('.additional-media');
    $thumbWrapper = $thumbContainer.parent();
    $thumbnails = $('.thumbnail-image', $thumbContainer);
    thumbsWidth = 0;
    $thumbnails.each(function() {
      return thumbsWidth += $(this).outerWidth(true);
    });
    if (thumbsWidth > $thumbWrapper.innerWidth()) {
      return $thumbContainer.width(thumbsWidth);
    }
  };
  return {
    beforeUpdate: beforeUpdate,
    update: update
  };
})();
