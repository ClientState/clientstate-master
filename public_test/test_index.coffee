# {assert} = require "chai"

# mock OAuth
window.OAuth = {
  calls: {
    initialize: 0
    setOAuthdURL: 0
    popup: 0
  }
  initialize: () ->
    @calls.initialize += 1
  setOAuthdURL: () ->
    @calls.setOAuthdURL += 1
  popup: (provider, cb) ->
    @calls.popup += 1
    cb null, {access_token: "ABC"}
}

describe 'anything', () ->

  beforeEach module 'CSMApp'

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    ctrl = $controller 'CSMController', {
      $scope: scope
    }

  it 'calls OAuth.popup on github login', (done) ->
    assert.equal scope.$storage.github_access_token, undefined
    scope.github_login()
    assert.equal OAuth.calls.popup, 1
    assert.equal scope.$storage.github_access_token, "ABC"
    done()
