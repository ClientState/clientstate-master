// Generated by CoffeeScript 1.8.0
(function() {
  var App, ProviderIDSecret, ProviderLoginDetails, User, assert, models, _ref;

  models = (_ref = require("../models"), User = _ref.User, ProviderIDSecret = _ref.ProviderIDSecret, ProviderLoginDetails = _ref.ProviderLoginDetails, App = _ref.App, _ref);

  assert = require("chai").assert;

  require("./global_mocks")();

  beforeEach(function(done) {
    var k, v;
    docker.reset();
    return knexion.raw("TRUNCATE TABLE " + (((function() {
      var _results;
      _results = [];
      for (k in models) {
        v = models[k];
        _results.push(v.tableName);
      }
      return _results;
    })()).join(',')) + " RESTART IDENTITY").then(function() {
      return done();
    });
  });

  describe('User model tests', function() {
    return it('autoincrements id, insert and fetchAll work', function(done) {
      var user;
      user = new User();
      return user.save(null, {
        method: "insert"
      }).then(function(model) {
        assert(model.id === 1);
        return (new User()).save(null, {
          method: "insert"
        }).then(function(m2) {
          assert(m2.id === 2);
          return User.fetchAll().then(function(res) {
            assert(res.models.length === 2);
            return done();
          });
        });
      });
    });
  });

  describe('Truncate worked', function() {
    return it('has no Users', function(done) {
      return User.fetchAll().then(function(res) {
        assert(res.models.length === 0);
        return done();
      });
    });
  });

  describe('Transaction', function() {
    it('rolls back on error', function(done) {
      var tx;
      tx = bookshelf.transaction(function(t) {
        return (new User).save(null, {
          method: "insert",
          transacting: t
        }).then(function(m1) {
          return (new User).save({
            oops: "nope"
          }, {
            method: "insert",
            transacting: t
          }).then(function() {});
        });
      });
      return tx["catch"](function(err) {
        return User.fetchAll().then(function(res) {
          assert(res.models.length === 0);
          return done();
        });
      });
    });
    return it('succeeds when no error', function(done) {
      var tx;
      tx = bookshelf.transaction(function(t) {
        return (new User).save(null, {
          method: "insert",
          transacting: t
        }).then(function(m1) {
          return (new User).save(null, {
            method: "insert",
            transacting: t
          }).then(function(m2) {});
        });
      });
      return tx.then(function() {
        return User.fetchAll().then(function(res) {
          assert(res.models.length === 2);
          return done();
        });
      });
    });
  });

  describe('User has many ProviderLoginDetails', function() {
    return it('User.logins returns ProviderLoginDetails', function(done) {
      return (new User).save().then(function(user) {
        var pld;
        pld = new ProviderLoginDetails({
          id: "razzafrazza",
          provider: "github",
          data: '{"some": "thing"}',
          user_id: user.id
        });
        return pld.save(null, {
          method: "insert"
        }).then(function(new_pld) {
          return new_pld.user().fetch().then(function(reluser) {
            var _ref1;
            assert((reluser.get('id') === (_ref1 = user.id) && _ref1 === 1));
            return reluser.logins().fetch().then(function(plds) {
              assert(plds.models[0].get('id') === 'razzafrazza');
              return done();
            });
          });
        });
      });
    });
  });

  describe('Collections', function() {
    beforeEach(function(done) {
      return (new User).save().then(function(user) {
        return done();
      });
    });
    return it('fetching User.collection gives back user', function(done) {
      return User.collection().fetch().then(function(collection) {
        assert(collection.models[0].id === 1);
        return done();
      });
    });
  });

  describe('create new redis Service', function() {
    beforeEach(function(done) {
      return new App({
        id: uuid.v4()
      }).save(null, {
        method: "insert"
      }).then(function(app) {
        return new ProviderIDSecret({
          app_id: app.id
        }).save(null, {
          method: "insert"
        }).then(function(pis) {
          return done();
        });
      });
    });
    return it('calls docker correctly when app.launch_service', function(done) {
      return new App({
        id: "other-uuid"
      }).fetch({
        withRelated: ["provider_id_secrets"]
      }).then(function(app) {
        var opts;
        opts = {};
        return app.launch_service(opts, function() {
          assert.equal(docker.callCounts.createContainer, 2);
          return done();
        });
      });
    });
  });

}).call(this);
