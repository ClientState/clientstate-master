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
      $scope.$apply()
      $scope.get_apps()
    return

  $scope.get_apps = () ->
    $http.get('/apps').success (res) ->
      $scope.apps = res

  $scope.create_new_app = () ->
    $http.post('/apps', name: $scope.newAppName).success (res) ->
      # should we just insert into our array without calling over http?
      $scope.get_apps()

CSMController.$inject = ['$scope', '$http']
angular.module('CSMApp').controller 'CSMController', CSMController
