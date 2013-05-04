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
            .when '/about',
                templateUrl: 'views/main.html',
                controller: 'MainCtrl'
            .otherwise
                redirectTo: '/map'


    .run ($rootScope, $location, GoogleMap) ->
        rootScope = $rootScope
        rootScope.map = null
        rootScope.navBarHeight = 40

        # return true if path is for map
        rootScope.mapShown = ->
            mapShown = $location.path().indexOf('/map') > -1

            return mapShown
