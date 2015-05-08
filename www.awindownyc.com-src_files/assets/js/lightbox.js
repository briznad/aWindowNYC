var aWindow;

aWindow = aWindow || {};

aWindow.lightbox = (function() {
  'use strict';
  var init, options, _closeLightbox, _controlLightbox, _openLightbox;
  options = {
    enabledElements: ['.primary-image:not(.sub-item)', '.thumbnail-image:not(.sub-item)']
  };
  init = function(opts) {
    if (opts == null) {
      opts = {};
    }
    _.extend(options, opts);
    aWindow.cache.$body.on('click', options.enabledElements.join(', '), _openLightbox);
    aWindow.cache.$body.on('click', '.lightbox-control', _controlLightbox);
    return aWindow.cache.$body.on('click', '.lightbox-overlay', _closeLightbox);
  };
  _openLightbox = function(e) {
    var $el, $target;
    e.preventDefault();
    e.stopPropagation();
    $el = $(this);
    console.log($el);
    $target = $el.is('a') ? $el : $el.closest('a');
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
