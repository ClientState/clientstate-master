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
      $scope.github_access_token = provider_data.access_token
      $scope.$apply()
      $scope.get_apps()
    return

  $scope.get_apps = () ->
    console.log "get_apps!"

CSMController.$inject = ['$scope', '$http']
angular.module('CSMApp').controller 'CSMController', CSMController
