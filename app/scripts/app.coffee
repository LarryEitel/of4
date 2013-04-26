'use strict'

angular.module('of4App', [])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/map',
        templateUrl: 'views/map.html',
        controller: 'MapCtrl'
      .otherwise
        redirectTo: '/'
    
  .run ($rootScope, $location) ->
    rootScope = $rootScope
    rootScope.navBarHeight = 40

    rootScope.mapShown = ->
      return $location.path().indexOf('/map') > -1