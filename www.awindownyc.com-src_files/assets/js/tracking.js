var aWindow;

aWindow = aWindow || {};

aWindow.tracking = (function() {
  'use strict';
  var addToCart, heliumCartEvents, init, trackPage;
  init = function() {};
  trackPage = function(req) {
    return _gaq.push(['_trackPageview', req]);
  };
  addToCart = function() {
    return _gaq.push(['_trackEvent', 'cart', 'add to cart', window.location.pathname, void 0, true]);
  };
  heliumCartEvents = function() {
    var ajaxBuster, counter;
    counter = 0;
    ajaxBuster = function(selector, action, postClickCallback) {
      var t;
      if (postClickCallback == null) {
        postClickCallback = function() {};
      }
      if ($(selector).length) {
        return $(selector).on('click', function() {
          _gaq.push(['_trackEvent', 'cart', action, action !== 'remove from cart' ? window.location.pathname : $(this).parent('.paper_row').parent().attr('data-id'), void 0, true]);
          return postClickCallback();
        });
      } else if (counter < 3000) {
        counter++;
        return t = setTimeout(function() {
          return ajaxBuster(selector, action, postClickCallback);
        }, 100);
      }
    };
    ajaxBuster('.paper_row .remove.item', 'remove from cart', function() {
      return ajaxBuster('#helium_checkout_server_error .helium_checkout_button', 'close cart');
    });
    ajaxBuster('#checkout_submit', 'place order');
    return ajaxBuster('#checkout_cancel', 'continue shopping');
  };
  return {
    init: init,
    trackPage: trackPage,
    addToCart: addToCart,
    heliumCartEvents: heliumCartEvents
  };
})();
