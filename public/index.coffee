'use strict'

window.CSMApp = angular.module 'CSMApp', ['ngStorage']

CSMApp.filter 'Objectkeys', () ->
  return (input) ->
    return Object.keys input


CSMController = ($scope, $http, $localStorage) ->
  window.scope = $scope
  $scope.$storage = $localStorage

  $scope.clientid = "b6d50cdc7d9372561081"

  $scope.ack_token = () ->
    $http.defaults.headers.common.access_token =
      $scope.$storage.github_access_token
    $scope.get_apps()

  $scope.logout = () ->
    $scope.$storage.github_access_token = undefined

  $scope.github_login = () ->
    OAuth.initialize $scope.clientid
    OAuth.setOAuthdURL window.location.origin
    OAuth.popup "github", (err, provider_data) ->

      if err?
        console.log err.stack

      $scope.$storage.github_access_token = provider_data.access_token
      $scope.ack_token()
    return

  $scope.get_apps = (cb = ()->) ->
    $http.get('/apps').success (res) ->
      $scope.apps = res
      cb()

  $scope.create_new_app = () ->
    $http.post('/apps', name: $scope.newAppName).success (res) ->
      # should we just insert into our array without calling over http?
      $scope.newAppName = ""
      $scope.get_apps()

  $scope.save_app = (app) ->
    # save name change
    $http.put("/apps/#{app.id}", {name: app.name}).success (res) ->
      $scope.get_apps () ->
        # TODO - let's flash some confirmation that things went well.
        # alert "BOOM!"

  $scope.create_service = (type, app_id) ->
    console.log "create_service", type, app_id
    $http.post("/apps/#{app_id}/services", {type: type}).success (res) ->
      $scope.get_apps()

  $scope.create_pis = (app) ->
    d =
      # TODO: support more providers
      provider: "github"
      client_id: app.new_client_id
      client_secret: app.new_client_secret
      oauth_redirect_url: app.new_oauth_redirect_url

    $http.post("/apps/#{app.id}/provider-id-secrets", d).then (res) ->
      $scope.get_apps()

  init = () ->
    if $scope.$storage.github_access_token?
      $scope.ack_token()
  init()


CSMController.$inject = ['$scope', '$http', '$localStorage']
angular.module('CSMApp').controller 'CSMController', CSMController
