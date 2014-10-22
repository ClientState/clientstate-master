// Generated by CoffeeScript 1.8.0
(function() {
  'use strict';
  var CSMController;

  window.CSMApp = angular.module('CSMApp', []);

  CSMController = function($scope, $http) {
    window.scope = $scope;
    $scope.clientid = "b6d50cdc7d9372561081";
    $scope.github_login = function() {
      OAuth.initialize($scope.clientid);
      OAuth.setOAuthdURL(window.location.origin);
      OAuth.popup("github", function(err, provider_data) {
        console.log(err, provider_data);
        if (err != null) {
          console.log(err.stack);
        }
        $scope.github_access_token = provider_data.access_token;
        $http.defaults.headers.common.access_token = $scope.github_access_token;
        $scope.$apply();
        return $scope.get_apps();
      });
    };
    $scope.get_apps = function() {
      return $http.get('/apps').success(function(res) {
        return $scope.apps = res;
      });
    };
    $scope.create_new_app = function() {
      return $http.post('/apps', {
        name: $scope.newAppName
      }).success(function(res) {
        $scope.newAppName = "";
        return $scope.get_apps();
      });
    };
    $scope.create_service = function(name, app_id) {
      return $http.post("/apps/" + app_id + "/services", {
        name: name
      }).success(function(res) {
        return $scope.get_apps();
      });
    };
    return $scope.create_pis = function(app) {
      var d;
      d = {
        provider: "github",
        client_id: app.new_client_id,
        client_secret: app.new_client_secret,
        oauth_redirect_url: app.new_oauth_redirect_url
      };
      return $http.post("/apps/" + app.id + "/provider-id-secrets", d).then(function(res) {
        return $scope.get_apps();
      });
    };
  };

  CSMController.$inject = ['$scope', '$http'];

  angular.module('CSMApp').controller('CSMController', CSMController);

}).call(this);
