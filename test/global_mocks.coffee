uuid = {
  v4: () ->
    "other-uuid"
}


class MockContainer

  callCounts: {
    start: 0
    inspect: 0
  }

  start: (opts, cb) ->
    @callCounts.start += 1
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
  }

  createContainer: (opts, cb) ->
    @callCounts.createContainer += 1
    cb(null, new MockContainer())

  reset: () ->
    for k,v of @callCounts
      @callCounts[k] = 0


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
