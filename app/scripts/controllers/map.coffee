'use strict'

angular.module('of4App')
    .controller 'MapCtrl', ["$scope", "GoogleMap", "$route", "$routeParams", "$location", (scope, GoogleMap, route, routeParams, location) ->
        scope.map = GoogleMap
        scope.route = route
        scope.routeParams = routeParams
        scope.location = location
        scope.$watch "routeParams", ((newVal, oldVal) ->
            console.log "routeParams"
            angular.forEach newVal, (v, k) ->
                location.search k, v
        ), true
    ]