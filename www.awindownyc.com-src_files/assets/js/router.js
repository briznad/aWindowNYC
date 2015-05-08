var aWindow;

aWindow = aWindow || {};

aWindow.router = (function() {
  'use strict';
  var init, initRoutes, _testHash;
  init = function(callback) {
    if (callback == null) {
      callback = function() {};
    }
    initRoutes();
    _testHash();
    return callback();
  };
  initRoutes = function() {
    var routes;
    return routes = new Davis(function() {
      this.configure(function(config) {
        return config.generateRequestOnPageLoad = true;
      });
      this.before(aWindow.updateView.beforeUpdate);
      this.after(function(req) {
        return aWindow.tracking.trackPage(req.path);
      });
      this.get('/', function() {
        return aWindow.updateView.update('meta', 'root');
      });
      this.get('/index.html', function() {
        return aWindow.updateView.update('meta', 'root');
      });
      this.get('/:titleNormalized', function(req) {
        return aWindow.updateView.update('meta', req.params.titleNormalized, !req.queryString ? false : {
          title: req.params.title
        });
      });
      this.get(':titleNormalized', function(req) {
        return aWindow.updateView.update('meta', req.params.titleNormalized, !req.queryString ? false : {
          title: req.params.title
        });
      });
      this.get('/:type/:titleNormalized', function(req) {
        return aWindow.updateView.update(req.params.type, req.params.titleNormalized);
      });
      this.get('/item/:parentItem/:childItem', function(req) {
        return aWindow.updateView.update('sub-item', req.params.childItem);
      });
      return this.post('/contact', aWindow.contact.send);
    });
  };
  _testHash = function() {
    if (location.hash) {
      return Davis.location.assign(new Davis.Request(location.hash.replace(/^#/, '')));
    }
  };
  return {
    init: init
  };
})();
