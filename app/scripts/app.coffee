'use strict'

angular.module('of4App', [])
    .config ($routeProvider, $locationProvider) ->
        $locationProvider.html5Mode(true) #.hashPrefix "!"

        $routeProvider
            .when '/menu',
                templateUrl: 'views/menu.html',
                controller: 'MainCtrl'
            .when '/list',
                templateUrl: 'views/list.html',
                controller: 'MainCtrl'
            .when '/map',
                templateUrl: 'views/map.html',
                controller: 'MainCtrl'
            .when '/',
                templateUrl: 'views/main.html',
                controller: 'MainCtrl'
            .otherwise
                templateUrl: 'views/main.html'
                controller: 'MainCtrl'

    
    .run ($rootScope, $location) ->
        rootScope = $rootScope
        rootScope.navBarHeight = 40

        # return true if path is for map
        rootScope.mapShown = ->
            # console.log 'rootScope.mapShown.location.path ' + $location.path()
            return $location.path().indexOf('/map') > -1
