// Generated by CoffeeScript 1.6.1
(function() {
  'use strict';
  angular.module('of4App', []).config(function($routeProvider) {
    return $routeProvider.when('/menu', {
      templateUrl: 'views/menu.html',
      controller: 'MainCtrl'
    }).when('/list', {
      templateUrl: 'views/list.html',
      controller: 'MainCtrl'
    }).when('/map', {
      templateUrl: 'views/map.html',
      controller: 'MapCtrl'
    }).when('/about', {
      templateUrl: 'views/main.html',
      controller: 'MainCtrl'
    }).otherwise({
      redirectTo: '/map'
    });
  }).run(function($rootScope, $location, GoogleMap) {
    var rootScope;
    rootScope = $rootScope;
    rootScope.navBarHeight = 40;
    console.log('run');
    return rootScope.mapShown = function() {
      var mapShown;
      mapShown = $location.path().indexOf('/map') > -1;
      return mapShown;
    };
  });

}).call(this);
