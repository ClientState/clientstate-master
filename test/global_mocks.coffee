uuid = {
  v4: () ->
    "other-uuid"
}


class MockContainer

  callCounts: {
    start: 0
    stop: 0
    remove: 0
    inspect: 0
  }

  start: (opts, cb) ->
    @callCounts.start += 1
    cb()
  stop: (cb) ->
    @callCounts.stop += 1
    cb()
  remove: (cb) ->
    @callCounts.remove += 1
    cb()
  inspect: (cb) ->
    @callCounts.inspect += 1
    info = {
      Id: Math.random().toString().substr(2, 5)
      Name: "mock_container"
      NetworkSettings: {
        Ports: {
          '3000/tcp': [
            {HostIp: '0.0.0.0', HostPort: '49220'}
          ]
        }
      }
    }
    cb null, info


class MockDocker

  callCounts: {
    createContainer: 0
    getContainer: 0
  }
  arguments: {
    createContainer: []
    getContainer: []
  }

  createContainer: (opts, cb) ->
    @callCounts.createContainer += 1
    @arguments.createContainer.push {'0': opts, '1': cb}
    cb(null, new MockContainer())

  getContainer: (id) ->
    @callCounts.getContainer += 1
    @arguments.getContainer.push {'0': id}
    return new MockContainer()

  reset: () ->
    for k,v of @callCounts
      @callCounts[k] = 0
    for k,v of @arguments
      @arguments[k] = []


class MockRedisClient

  callCounts: {
    set: 0
    get: 0
  }

  set: (key, value, cb=()->) ->
    @callCounts.set += 1
    cb()

  get: (key) ->
    @callCounts.get += 1
    cb 'XXX.X.X.X:YYYY'


module.exports = () ->
  global.uuid = uuid
  global.docker = new MockDocker()
  global.redis_client = new MockRedisClient()
