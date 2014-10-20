// Generated by CoffeeScript 1.8.0
(function() {
  var Promise, ProviderLoginDetails, User, assert, github_complete, github_result, models, _ref;

  assert = require("chai").assert;

  Promise = require("bluebird");

  models = (_ref = require("../models"), User = _ref.User, ProviderLoginDetails = _ref.ProviderLoginDetails, _ref);

  github_complete = require("../oauth-events").github_complete;

  github_result = {
    data: {
      access_token: 'abcdef',
      token_type: 'bearer',
      scope: ''
    },
    status: 'success',
    state: 'qwerty',
    provider: 'github',
    user_data: {
      login: 'skyl',
      id: 61438,
      avatar_url: 'https://avatars.githubusercontent.com/u/61438?v=2',
      gravatar_id: '',
      url: 'https://api.github.com/users/skyl',
      html_url: 'https://github.com/skyl',
      followers_url: 'https://api.github.com/users/skyl/followers',
      following_url: 'https://api.github.com/users/skyl/following{/other_user}',
      gists_url: 'https://api.github.com/users/skyl/gists{/gist_id}',
      starred_url: 'https://api.github.com/users/skyl/starred{/owner}{/repo}',
      subscriptions_url: 'https://api.github.com/users/skyl/subscriptions',
      organizations_url: 'https://api.github.com/users/skyl/orgs',
      repos_url: 'https://api.github.com/users/skyl/repos',
      events_url: 'https://api.github.com/users/skyl/events{/privacy}',
      received_events_url: 'https://api.github.com/users/skyl/received_events',
      type: 'User',
      site_admin: false,
      name: 'Skylar Saveland',
      company: 'JPMorgan Chase',
      blog: 'http://skyl.org/',
      location: 'San Francisco',
      email: 'skylar.saveland@gmail.com',
      hireable: true,
      bio: null,
      public_repos: 104,
      public_gists: 31,
      followers: 57,
      following: 128,
      created_at: '2009-03-09T01:41:19Z',
      updated_at: '2014-10-17T23:41:51Z'
    }
  };

  beforeEach(function(done) {
    var k, v;
    return knexion.raw("TRUNCATE TABLE " + (((function() {
      var _results;
      _results = [];
      for (k in models) {
        v = models[k];
        _results.push(v.tableName);
      }
      return _results;
    })()).join(',')) + " RESTART IDENTITY").then(done());
  });

  describe('Github Oauth Complete', function() {
    it('Users are empty', function(done) {
      return (new User()).fetchAll().then(function(collection) {
        assert(collection.length === 0);
        return done();
      });
    });
    it('Create new User with new login details', function(done) {
      var p;
      p = Promise.resolve(github_complete(github_result));
      return p.then(function() {
        return (new User({
          id: 1
        })).logins().fetch().then(function(logins) {
          assert(logins.models[0].id === '61438');
          return done();
        });
      });
    });
    return it('Called multiple times - no error, 1 user with 1 PLD', function(done) {
      var p;
      p = Promise.resolve(github_complete(github_result));
      return p.then(function() {
        var p2;
        p2 = Promise.resolve(github_complete(github_result));
        return p2.then(function() {
          return (new User()).fetchAll().then(function(collection) {
            assert(collection.length === 1);
            return collection.models[0].logins().fetch().then(function(logins) {
              assert(logins.length === 1);
              return done();
            });
          });
        });
      });
    });

    /*
     * bad test, hrm ..
    it 'Called simulatneously, causes rollback, 1 user - 1 PLD', (done) ->
      github_complete github_result
      p = Promise.resolve github_complete github_result
      p.then (err) ->
        assert err.detail is 'Key (id)=(61438) already exists.', "NOPE"
        (new User()).fetchAll().then (collection) ->
          assert collection.length is 1
          collection.models[0].logins().fetch().then (logins) ->
            assert logins.length is 1
            done()
     */
  });

}).call(this);
