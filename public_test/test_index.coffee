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

describe 'CSMController tests', () ->

  beforeEach module 'CSMApp'

  beforeEach inject ($controller, $rootScope, _$httpBackend_) ->
    window.$httpBackend = _$httpBackend_
    $httpBackend.when("GET", "/apps").respond([{}, {}, {}])
    $httpBackend.when("POST", "/apps").respond "OK"
    scope = $rootScope.$new()
    ctrl = $controller 'CSMController', {
      $scope: scope
    }

  it 'github login calls OAuth.popup', (done) ->
    assert.equal scope.$storage.github_access_token, undefined
    scope.github_login()
    assert.equal OAuth.calls.popup, 1
    assert.equal scope.$storage.github_access_token, "ABC"
    done()

  it 'logout logs out', (done) ->
    scope.$storage.github_access_token = "foobar"
    scope.logout()
    assert.equal scope.$storage.github_access_token, undefined
    done()

  it 'makes scope.apps the response of get /apps', (done) ->
    scope.get_apps () ->
      assert.equal scope.apps.length, 3
      done()
    $httpBackend.flush()

  it 'post to create_new_app sets newAppName to blank', (done) ->
    scope.newAppName = "this"
    scope.create_new_app () ->
      assert.equal scope.newAppName, ""
      assert.equal scope.apps.length, 3
      done()
    $httpBackend.flush()

  return