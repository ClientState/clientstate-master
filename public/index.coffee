'use strict'

window.CSMApp = angular.module 'CSMApp', []


CSMController = ($scope, $http) ->
  window.scope = $scope

  $scope.clientid = "b6d50cdc7d9372561081"

  $scope.github_login = () ->
    OAuth.initialize $scope.clientid
    OAuth.setOAuthdURL window.location.origin
    OAuth.popup "github", (err, provider_data) ->
      console.log err, provider_data
      if err?
        console.log err.stack
      # TODO - localStorage
      $scope.github_access_token = provider_data.access_token
      $http.defaults.headers.common.access_token = $scope.github_access_token

      # TODO, access_token is no good for a second?
      setTimeout(
        () -> $scope.get_apps(),
        100
      )
    return

  $scope.get_apps = () ->
    $http.get('/apps').success (res) ->
      $scope.apps = res

  $scope.create_new_app = () ->
    $http.post('/apps', name: $scope.newAppName).success (res) ->
      # should we just insert into our array without calling over http?
      $scope.newAppName = ""
      $scope.get_apps()

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


CSMController.$inject = ['$scope', '$http']
angular.module('CSMApp').controller 'CSMController', CSMController
