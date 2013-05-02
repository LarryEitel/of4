'use strict'

angular.module('of4App')
    .controller 'MainCtrl', ($scope, GoogleMap) ->
        $scope.map = GoogleMap
        $scope.map.resizeMapEl()


