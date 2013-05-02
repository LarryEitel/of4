'use strict'

angular.module('of4App', [])
    .config ($routeProvider) ->

        $routeProvider
            .when '/menu',
                templateUrl: 'views/menu.html',
                controller: 'MainCtrl'
            .when '/list',
                templateUrl: 'views/list.html',
                controller: 'MainCtrl'
            .when '/map',
                templateUrl: 'views/map.html',
                controller: 'MapCtrl'
            .when '/',
                templateUrl: 'views/main.html',
                controller: 'MainCtrl'
            .otherwise
                templateUrl: 'views/main.html'
                controller: 'MainCtrl'


    .run ($rootScope, $location) ->
        rootScope = $rootScope
        rootScope.navBarHeight = 40
        rootScope.mapShownOnce = false

        # return true if path is for map
        rootScope.mapShown = ->
            # console.log 'rootScope.mapShown.location.path ' + $location.path()
            mapShown = $location.path().indexOf('/map') > -1

            # need way to force Google Maps to load initial map!!
            if mapShown and not rootScope.mapShownOnce
                rootScope.mapShownOnce = true

            return mapShown
