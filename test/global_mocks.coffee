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


docker = new MockDocker()

module.exports = () ->
  global.uuid = uuid
  global.docker = docker
