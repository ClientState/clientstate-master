// Generated by CoffeeScript 1.8.0
(function() {
  var App, ProviderIDSecret, ProviderLoginDetails, User, app, assert, createAppForUser, models, request, _ref;

  request = require('supertest');

  assert = require("chai").assert;

  app = require('../server').app;

  models = (_ref = require("../models"), User = _ref.User, ProviderLoginDetails = _ref.ProviderLoginDetails, App = _ref.App, ProviderIDSecret = _ref.ProviderIDSecret, _ref);

  require("./global_mocks")();

  createAppForUser = function(done) {
    var k, v;
    return knexion.raw("TRUNCATE TABLE " + (((function() {
      var _results;
      _results = [];
      for (k in models) {
        v = models[k];
        _results.push(v.tableName);
      }
      return _results;
    })()).join(',')) + " RESTART IDENTITY").then(function() {
      return (new User).save().then(function(user) {
        var details;
        details = {
          id: "61438",
          provider: "github",
          access_token: "qwerty",
          data: {},
          user_id: user.get('id')
        };
        return new ProviderLoginDetails(details).save(null, {
          method: "insert"
        }).then(function(pld) {
          return new App({
            id: "this-uuid",
            name: "meltodies",
            user_id: user.id
          }).save(null, {
            method: "insert"
          }).then(function(app) {
            return done();
          });
        });
      });
    });
  };

  describe('Get Apps for User', function() {
    beforeEach(createAppForUser);
    it('returns the Apps for user as JSON', function(done) {
      return request(app).get('/apps').set({
        "access_token": "qwerty"
      }).expect(200).end(function(err, res) {
        assert(res.body[0].name === "meltodies");
        return done();
      });
    });
    it('returns 403 with no access_token', function(done) {
      return request(app).get('/apps').expect(403, done);
    });
    return it('returns 403 with non-existent access_token', function(done) {
      return request(app).get('/apps').set({
        access_token: "nonExiStent"
      }).expect(403, done);
    });
  });

  describe('Create new App for User', function() {
    beforeEach(createAppForUser);
    return it('creates App through REST', function(done) {
      return request(app).post('/apps').set({
        access_token: "qwerty"
      }).set({
        "Content-Type": "application/json;charset=UTF-8"
      }).send('{"name":"Frilz-not-kidding"}').expect(200).end(function(err, res) {
        return new App({
          user_id: 1
        }).fetchAll().then(function(apps) {
          assert.equal(apps.length, 2);
          assert.equal(apps._byId['other-uuid'].get('name'), "Frilz-not-kidding");
          return done();
        });
      });
    });
  });

  describe('Services for App', function() {
    beforeEach(createAppForUser);
    return it('Create Service for App', function(done) {
      return request(app).post('/apps/this-uuid/launch').set({
        access_token: "qwerty"
      }).set({
        "Content-Type": "application/json;charset=UTF-8"
      }).send('').expect(200).end(function(err, res) {
        return new App({
          id: "this-uuid"
        }).containers().fetch().then(function(collection) {
          assert.equal(collection.models.length, 2);
          assert.equal(docker.callCounts.createContainer, 2);
          return done();
        });
      });
    });
  });

  describe('ProviderIDSecrets for App', function() {
    beforeEach(createAppForUser);
    return it('Create ProviderIDSecret with POST', function(done) {
      var j;
      j = {
        client_id: "client_id_asdf",
        client_secret: "client_secret_asdf",
        oauth_redirect_url: "http://example.com/auth/github"
      };
      return request(app).post('/apps/this-uuid/provider-id-secrets').set({
        access_token: "qwerty"
      }).set({
        "Content-Type": "application/json;charset=UTF-8"
      }).send(JSON.stringify(j)).expect(200).end(function(err, res) {
        return new ProviderIDSecret({
          id: 1
        }).fetch().then(function(pis) {
          assert.equal(pis.get("app_id"), "this-uuid");
          assert.equal(pis.get("client_id"), j.client_id);
          assert.equal(pis.get("client_secret"), j.client_secret);
          assert.equal(pis.get("oauth_redirect_url"), j.oauth_redirect_url);
          return done();
        });
      });
    });
  });

}).call(this);
