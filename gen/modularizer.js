// Generated by CoffeeScript 1.9.0
(function() {
  var Modularizer;

  Modularizer = (function() {
    function Modularizer() {}

    Modularizer.prototype.install = function(app, module) {
      app.use(express["static"](module.context, path.join(__dirname, 'web-private/client')));
      return app.use(module.restContext, require('./web-public/server/router'));
    };

    return Modularizer;

  })();

}).call(this);
