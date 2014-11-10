// Generated by CoffeeScript 1.8.0
(function() {
  var app, auth, bodyParser, express, mod, oauth, server;

  global.uuid = require('node-uuid');

  express = require('express');

  app = express();

  oauth = require('oauth-express');

  mod = require('./models');

  bodyParser = require('body-parser');

  app.use(bodyParser.json());

  app.use(bodyParser.urlencoded({
    extended: true
  }));

  app.get('/auth/:provider', oauth.handlers.auth_provider_redirect);

  app.get('/auth_callback/:provider', oauth.handlers.auth_callback);

  oauth.emitters.github.on('complete', require("./oauth-events").github_complete);

  app.use("/public", express["static"]("" + __dirname + "/public"));

  app.use("/lib", express["static"]("" + __dirname + "/bower_components"));

  app.use("/", express["static"]("" + __dirname + "/views"));

  app.get("/services/:id", function(req, res) {
    return new mod.Service({
      id: req.params.id
    }).fetch({
      withRelated: ['containers']
    }).then(function(service) {
      return res.send(service.port_json);
    });
  });

  auth = function(req, res, next) {
    var abort;
    abort = function() {
      res.status(403).write("valid access_token header required");
      return res.send();
    };
    if (req.headers.access_token === void 0) {
      abort();
    }
    return new mod.ProviderLoginDetails({
      access_token: req.headers.access_token
    }).fetch({
      withRelated: ['user']
    }).then(function(pld) {
      var user;
      if (pld === null) {
        abort();
        return;
      }
      user = pld.related('user');
      if (user) {
        req.user = user;
        next();
        return;
      }
      return abort();
    });
  };

  app.use("/apps", auth);

  app.get("/apps", function(req, res) {
    return new mod.App({
      user_id: req.user.id
    }).fetchAll({
      withRelated: ['services', 'services.containers', 'provider_id_secrets']
    }).then(function(collection) {
      res.send(collection.toJSON());
    });
  });

  app.post("/apps", function(req, res) {
    app = new mod.App({
      id: uuid.v4(),
      name: req.body.name,
      user_id: req.user.id
    });
    return app.save(null, {
      method: "insert"
    }).then(function() {
      res.send("OK");
    });
  });

  app.put("/apps/:id", function(req, res) {
    return new mod.App({
      id: req.params.id,
      user_id: req.user.id
    }).save({
      name: req.body.name
    }, {
      method: "update"
    }).then(function(app) {
      res.send("OK");
    });
  });

  app.post("/apps/:id/provider-id-secrets", function(req, res) {
    var PIS;
    PIS = {
      provider: "github",
      app_id: req.params.id,
      client_id: req.body.client_id,
      client_secret: req.body.client_secret,
      oauth_redirect_url: req.body.oauth_redirect_url
    };
    return new mod.ProviderIDSecret(PIS).save(null, {
      method: "insert"
    }).then(function(pis) {
      return res.send("OK");
    });
  });

  app.get("/apps/:id/services", function(req, res) {
    return new mod.App({
      id: req.params.id,
      user_id: req.user.id
    }).services({
      withRelated: ['containers']
    }).fetch().then(function(services) {
      return res.send(services.toJSON());
    });
  });

  app.post("/apps/:id/services", function(req, res) {
    return new mod.App({
      id: req.params.id,
      user_id: req.user.id
    }).fetch({
      withRelated: ['provider_id_secrets']
    }).then(function(app_mod) {
      if (app_mod === null) {
        res.status(404).write("App not found");
        res.send();
        return;
      }
      return app_mod.create_new_service(req.body, function(service) {
        res.send(service.toJSON());
      });
    });
  });

  app["delete"]("/apps/:app_id/services/:service_id", function(req, res) {
    return new mod.App({
      id: req.params.app_id,
      user_id: req.user.id
    }).fetch({
      withRelated: ['services']
    }).then(function(app_mod) {
      var service;
      if (app_mod === null) {
        res.status(404).write("App not found");
        res.send();
        return;
      }
      service = app_mod.related('services')._byId[req.params.service_id];
      return service["delete"](function() {
        return res.send('OK');
      });
    });
  });

  server = app.listen(4000, function() {
    console.log('Listening on port %d', server.address().port);
    return console.log(process.env);
  });

  module.exports.app = app;

}).call(this);
