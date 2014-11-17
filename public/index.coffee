'use strict'

window.CSMApp = angular.module 'CSMApp', ['ngStorage']

CSMApp.filter 'Objectkeys', () ->
  return (input) ->
    return Object.keys input


CSMController = ($scope, $http, $localStorage) ->
  window.scope = $scope
  $scope.$storage = $localStorage

  $scope.github_clientid = "b6d50cdc7d9372561081"
  $scope.facebook_clientid = "827971890600150"

  $scope.ack_token = () ->
    $http.defaults.headers.common.access_token =
      $scope.$storage.github_access_token
    $scope.get_apps()

  $scope.logout = () ->
    delete $scope.$storage.github_access_token

  $scope.facebook_login = () ->
    OAuth.initialize $scope.facebook_clientid
    OAuth.setOAuthdURL window.location.origin
    OAuth.popup "facebook", (err, provider_data) ->
      console.log provider_data
      if err?
        console.log err.stack
      $scope.$storage.facebook_access_token = provider_data.access_token
      $scope.ack_token()
    return

  $scope.github_login = () ->
    OAuth.initialize $scope.github_clientid
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

  $scope.create_new_app = (cb = () ->) ->
    $http.post('/apps', name: $scope.newAppName).success (res) ->
      # should we just insert into our array without calling over http?
      $scope.newAppName = ""
      $scope.get_apps cb

  $scope.save_app = (app) ->
    # save name change
    $http.put("/apps/#{app.id}", {name: app.name}).success (res) ->
      $scope.get_apps () ->
        # TODO - let's flash some confirmation that things went well.
        # instead of this alert ...
        alert "Successfully Saved!"

  $scope.create_pis = (app) ->
    d =
      # TODO: support more providers
      provider: "github"
      client_id: app.new_client_id
      client_secret: app.new_client_secret
      oauth_redirect_url: app.new_oauth_redirect_url

    $http.post("/apps/#{app.id}/provider-id-secrets", d).then (res) ->
      $scope.get_apps()

  $scope.create_service = (type, app_id) ->
    $http.post("/apps/#{app_id}/services", {type: type}).success (res) ->
      $scope.get_apps()

  $scope.delete_service = (service) ->
    $http.delete(
      "/apps/#{service.app_id}/services/#{service.id}"
    ).success (res) ->
      $scope.get_apps()


  init = () ->
    if $scope.$storage.github_access_token?
      $scope.ack_token()
  init()


CSMController.$inject = ['$scope', '$http', '$localStorage']
angular.module('CSMApp').controller 'CSMController', CSMController
