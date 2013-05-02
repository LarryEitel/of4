'use strict'

angular.module('of4App')
    .controller 'MainCtrl', ($scope, GoogleMap) ->
        google.maps.trigger(map, 'resize')
        $scope.map = GoogleMap
        # $scope.$apply()


