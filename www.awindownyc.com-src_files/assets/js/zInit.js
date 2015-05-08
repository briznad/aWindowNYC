var aWindow;

aWindow = aWindow || {};

aWindow.init = (function() {
  'use strict';
  aWindow.template.init(function() {
    return aWindow.modelBuildr.init(function() {
      return aWindow.router.init();
    });
  });
  return aWindow.lightbox.init();
})();
