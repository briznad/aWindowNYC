var aWindow;

aWindow = aWindow || {};

aWindow.updateView = (function() {
  'use strict';
  var beforeUpdate, update, _addBodyClasses, _cartEvents, _computePageTitle, _initChooseDesign, _initEvents, _initLearnMore, _initParallax, _initThumbnails, _metaRedirects, _removeBodyClasses, _updateBodyClasses, _updateCurrentPage;
  beforeUpdate = function(request) {};
  update = function(type, titleNormalized, contactData) {
    var currentPage;
    if (contactData == null) {
      contactData = false;
    }
    currentPage = aWindow.model[type][titleNormalized];
    if (type === 'meta' && _metaRedirects(currentPage)) {
      return false;
    }
    _removeBodyClasses();
    _addBodyClasses(type, titleNormalized);
    _updateCurrentPage(type, titleNormalized);
    aWindow.cache.$title.add(aWindow.cache.$h1).text(_computePageTitle(type, currentPage.title));
    aWindow.cache.$dynamicContainer.html(aWindow.template.primaryTemplate({
      data: aWindow.model,
      currentType: type,
      currentTitleNormalized: titleNormalized,
      currentPage: currentPage,
      currentEdition: aWindow.model.settings.currentEdition,
      contactData: contactData
    }));
    return _initEvents(type, titleNormalized);
  };
  _metaRedirects = function(currentPage) {
    if (currentPage.metaListType) {
      if (!currentPage.displayOrder.length) {
        Davis.location.assign(new Davis.Request('/'));
        return true;
      } else if (currentPage.displayOrder.length === 1) {
        Davis.location.assign(new Davis.Request('/' + currentPage.metaListType + '/' + currentPage.displayOrder[0]));
        return true;
      }
    }
    return false;
  };
  _updateBodyClasses = function(method, classesArr) {
    return aWindow.cache.$body[method](classesArr.join(' '));
  };
  _removeBodyClasses = function() {
    if (aWindow.model.settings.currentPage) {
      return _updateBodyClasses('removeClass', [aWindow.model.settings.currentPage.type, aWindow.model.settings.currentPage.titleNormalized, 'purchase']);
    }
  };
  _addBodyClasses = function(type, titleNormalized) {
    return _updateBodyClasses('addClass', [type, titleNormalized]);
  };
  _updateCurrentPage = function(type, titleNormalized) {
    return aWindow.model.settings.currentPage = _.extend(aWindow.model.settings.currentPage || {}, {
      type: type,
      titleNormalized: titleNormalized
    });
  };
  _computePageTitle = function(type, title) {
    title = title.toLowerCase();
    if (title === 'root') {
      return 'a w i n d o w';
    } else if (type === 'edition') {
      return 'a w i n d o w | ' + 'edition ' + title;
    } else {
      return 'a w i n d o w | ' + title;
    }
  };
  _initEvents = function(type, titleNormalized) {
    var currentPage;
    currentPage = aWindow.model[type][titleNormalized];
    if (titleNormalized === 'root') {

    } else if (titleNormalized === 'edition-one-parallax') {
      return _initParallax();
    } else if (type === 'item' || type === 'sub-item') {
      _cartEvents(titleNormalized);
      _initLearnMore(currentPage);
      if (type === 'sub-item' || currentPage['sub-items'].length) {
        return _initChooseDesign(type, currentPage, titleNormalized);
      }
    } else if (['edition', 'project', 'event'].indexOf(type) !== -1) {
      return _initThumbnails();
    }
  };
  _initParallax = function() {
    var $scene, parallax, scene, toggleClass;
    scene = document.getElementById('parallax');
    parallax = new Parallax(scene);
    $scene = $(scene);
    toggleClass = function(item) {
      return $scene.toggleClass($(item).attr('class').split(' ')[2] + '-hover');
    };
    return $scene.find('.link-layer').on({
      mouseenter: function() {
        return toggleClass(this);
      },
      mouseleave: function() {
        return toggleClass(this);
      }
    });
  };
  _initLearnMore = function(currentPage) {
    if (currentPage.parentItem) {
      currentPage = aWindow.model.item[currentPage.parentItem];
    }
    return aWindow.cache.$body.off('click.learnMore').on('click.learnMore', '.learn-more-link', function(e) {
      e.preventDefault();
      return aWindow.modal.open(aWindow.template.learnMoreModule({
        currentPage: currentPage,
        attribution: currentPage.media.attribution
      }), {
        displayDuration: false,
        additionalClasses: ['learn-more-modal']
      });
    });
  };
  _initChooseDesign = function(type, currentPage, titleNormalized) {
    var currentSubItem;
    currentSubItem = false;
    if (type === 'sub-item') {
      currentSubItem = titleNormalized;
      titleNormalized = currentPage.parentItem;
      currentPage = aWindow.model.item[titleNormalized];
    }
    return aWindow.cache.$body.off('click.chooseDesign').on('click.chooseDesign', '.choose-design-btn, .choose-design-link', function(e) {
      e.preventDefault();
      aWindow.modal.open(aWindow.template.chooseDesignModule({
        data: aWindow.model,
        currentPage: currentPage,
        currentSubItem: currentSubItem,
        currentTitleNormalized: titleNormalized
      }), {
        displayDuration: false,
        additionalClasses: ['choose-design-modal']
      });
      return aWindow.cache.$body.off('click.destroyChooseDesignModal').on('click.destroyChooseDesignModal', '.sub-item-link', function() {
        return $(this).closest('.choose-design-modal').remove();
      });
    });
  };
  _cartEvents = function(titleNormalized) {
    return aWindow.cache.$body.off('click.addToCart').on('click.addToCart', '.order-link', function(e) {
      e.preventDefault();
      Helium.cart.add(titleNormalized);
      Helium.show();
      aWindow.tracking.addToCart();
      return aWindow.tracking.heliumCartEvents();
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
