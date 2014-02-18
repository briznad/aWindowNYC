var aWindow;

aWindow = aWindow || {};

aWindow.log = function(msg1, msg2) {
  'use strict';
  if (console.log != null) {
    if (msg2) {
      return console.log(msg1, msg2);
    } else {
      return console.log(msg1);
    }
  }
};
