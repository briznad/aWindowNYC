var aWindow;

aWindow = aWindow || {};

aWindow.lightbox = (function() {
  'use strict';
  var init, _closeLightbox, _controlLightbox, _openLightbox;
  init = function() {
    aWindow.cache.$body.on('click', 'a.primary-image:not(.sub-item), a.thumbnail-image:not(.sub-item)', _openLightbox);
    aWindow.cache.$body.on('click', '.lightbox-control', _controlLightbox);
    return aWindow.cache.$body.on('click', '.lightbox-overlay', _closeLightbox);
  };
  _openLightbox = function(e) {
    var $imgGroup, $target;
    e.preventDefault();
    e.stopPropagation();
    $target = $(this);
    $imgGroup = $(e.handleObj.selector);
    return aWindow.cache.$body.append(aWindow.template.lightboxModule({
      imgSource: $target.attr('href')
    }));
  };
  _controlLightbox = function(e) {
    e.preventDefault();
    e.stopPropagation();
    return aWindow.log('control');
  };
  _closeLightbox = function(e) {
    e.preventDefault();
    if (!$(e.target).is('.lightbox-container, .lightbox-img')) {
      return $(e.currentTarget).remove();
    }
  };
  return {
    init: init
  };
})();
