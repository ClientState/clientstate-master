// Generated by CoffeeScript 1.8.0
(function() {
  var MockContainer, MockDocker, MockRedisClient, uuid;

  uuid = {
    v4: function() {
      return "other-uuid";
    }
  };

  MockContainer = (function() {
    function MockContainer() {}

    MockContainer.prototype.callCounts = {
      start: 0,
      stop: 0,
      remove: 0,
      inspect: 0
    };

    MockContainer.prototype.start = function(opts, cb) {
      this.callCounts.start += 1;
      return cb();
    };

    MockContainer.prototype.stop = function(cb) {
      this.callCounts.stop += 1;
      return cb();
    };

    MockContainer.prototype.remove = function(cb) {
      this.callCounts.remove += 1;
      return cb();
    };

    MockContainer.prototype.inspect = function(cb) {
      var info;
      this.callCounts.inspect += 1;
      info = {
        Id: Math.random().toString().substr(2, 5),
        Name: "mock_container",
        NetworkSettings: {
          Ports: {
            '3000/tcp': [
              {
                HostIp: '0.0.0.0',
                HostPort: '49220'
              }
            ]
          }
        }
      };
      return cb(null, info);
    };

    return MockContainer;

  })();

  MockDocker = (function() {
    function MockDocker() {}

    MockDocker.prototype.callCounts = {
      createContainer: 0,
      getContainer: 0
    };

    MockDocker.prototype["arguments"] = {
      createContainer: [],
      getContainer: []
    };

    MockDocker.prototype.createContainer = function(opts, cb) {
      this.callCounts.createContainer += 1;
      this["arguments"].createContainer.push({
        '0': opts,
        '1': cb
      });
      return cb(null, new MockContainer());
    };

    MockDocker.prototype.getContainer = function(id) {
      this.callCounts.getContainer += 1;
      this["arguments"].getContainer.push({
        '0': id
      });
      return new MockContainer();
    };

    MockDocker.prototype.reset = function() {
      var k, v, _ref, _ref1, _results;
      _ref = this.callCounts;
      for (k in _ref) {
        v = _ref[k];
        this.callCounts[k] = 0;
      }
      _ref1 = this["arguments"];
      _results = [];
      for (k in _ref1) {
        v = _ref1[k];
        _results.push(this["arguments"][k] = []);
      }
      return _results;
    };

    return MockDocker;

  })();

  MockRedisClient = (function() {
    function MockRedisClient() {}

    MockRedisClient.prototype.callCounts = {
      set: 0,
      get: 0
    };

    MockRedisClient.prototype.set = function(key, value, cb) {
      if (cb == null) {
        cb = function() {};
      }
      this.callCounts.set += 1;
      return cb();
    };

    MockRedisClient.prototype.get = function(key) {
      this.callCounts.get += 1;
      return cb('XXX.X.X.X:YYYY');
    };

    return MockRedisClient;

  })();

  module.exports = function() {
    global.uuid = uuid;
    global.docker = new MockDocker();
    return global.redis_client = new MockRedisClient();
  };

}).call(this);
