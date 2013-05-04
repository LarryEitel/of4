'use strict'

angular.module('of4App')
    .controller 'MapCtrl', ($scope, GoogleMap) ->
        $scope.map = GoogleMap
