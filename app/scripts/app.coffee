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
                controller: 'MapCtrl',
                reloadOnSearch : false
            .when '/about',
                templateUrl: 'views/main.html',
                controller: 'MainCtrl'
            .otherwise
                redirectTo: '/map'


    .run ($rootScope, $location, GoogleMap) ->
        rootScope = $rootScope
        rootScope.navBarHeight = 40

        console.log 'run'
        # return true if path is for map
        rootScope.mapShown = ->
            mapShown = $location.path().indexOf('/map') > -1

            return mapShown
