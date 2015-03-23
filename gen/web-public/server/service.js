// Generated by CoffeeScript 1.9.0
(function() {
  var FastBricks, PublicService, fastB, query, sql;

  sql = require('sql-bricks');

  FastBricks = require('fast-bricks');

  fastB = new FastBricks();

  fastB.loadConfig('database-config.cson');

  query = fastB.query;

  PublicService = (function() {
    function PublicService() {}

    PublicService.prototype.signup = function(user, callback) {
      var email, username;
      if (!user.username) {
        callback("User name is required");
        return;
      }
      if (!user.password) {
        callback("Password is required");
        return;
      }
      if (!user.email) {
        callback("Email is required");
        return;
      }
      username = {
        username: user.username
      };
      email = {
        email: user.email
      };
      return query(sql.select().from('user').where(username), function(err, result) {
        if (result.length > 0) {
          callback("This user name is not available");
          return;
        }
        return query(sql.select().from('user').where(email), function(err, result) {
          if (result.length > 0) {
            callback("This email is not available");
            return;
          }
          return query(sql.insert('user', user), function(err, result) {
            user.id = result.insertId;
            return callback(void 0, user);
          });
        });
      });
    };

    PublicService.prototype.login = function(username, password, callback) {
      var expr;
      expr = sql.select().from('user').where({
        username: username,
        password: password
      });
      return query(expr, function(err, result) {
        if (result.length === 0) {
          return callback("This username/password is not valid");
        } else {
          return callback(void 0, result[0]);
        }
      });
    };

    return PublicService;

  })();

  module.exports = new PublicService();

}).call(this);
