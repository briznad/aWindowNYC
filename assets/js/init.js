var aWindow;

aWindow = aWindow || {};

aWindow.init = (function() {
  'use strict';
  return aWindow.modelBuildr.init(function() {
    return aWindow.router();
  });
})();
