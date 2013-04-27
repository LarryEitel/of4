###
!
The MIT License

Copyright (c) 2010-2012 Google, Inc. http://angularjs.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

angular-google-maps
https://github.com/nlaplante/angular-google-maps

@author Nicolas Laplante https://plus.google.com/108189012221374960701
###
(->
  
  #
  #   * Utility functions
  #   
  
  ###
  Check if 2 floating point numbers are equal
  
  @see http://stackoverflow.com/a/588014
  ###
  floatEqual = (f1, f2) ->
    Math.abs(f1 - f2) < 0.000001
  "use strict"
  
  # 
  #   * Create the model in a self-contained class where map-specific logic is 
  #   * done. This model will be used in the directive.
  #   
  MapModel = (->
    
    ###
    ###
    PrivateMapModel = (opts) ->
      _instance = null
      _markers = [] # caches the instances of google.maps.Marker
      _handlers = [] # event handlers
      _windows = [] # InfoWindow objects
      o = angular.extend({}, _defaults, opts)
      that = this
      currentInfoWindow = null
      @center = opts.center
      @zoom = o.zoom
      @draggable = o.draggable
      @dragging = false
      @selector = o.container
      @markers = []
      @options = o.options
      @draw = ->
        
        # TODO log error
        return  unless that.center?
        unless _instance?
          
          # Create a new map instance
          _instance = new google.maps.Map(that.selector, angular.extend(that.options,
            center: that.center
            zoom: that.zoom
            draggable: that.draggable
            mapTypeId: google.maps.MapTypeId.ROADMAP
          ))
          google.maps.event.addListener _instance, "dragstart", ->
            that.dragging = true

          google.maps.event.addListener _instance, "idle", ->
            that.dragging = false

          google.maps.event.addListener _instance, "drag", ->
            that.dragging = true

          google.maps.event.addListener _instance, "zoom_changed", ->
            that.zoom = _instance.getZoom()
            that.center = _instance.getCenter()

          google.maps.event.addListener _instance, "center_changed", ->
            that.center = _instance.getCenter()

          
          # Attach additional event listeners if needed
          if _handlers.length
            angular.forEach _handlers, (h, i) ->
              google.maps.event.addListener _instance, h.on, h.handler

        else
          
          # Refresh the existing instance
          google.maps.event.trigger _instance, "resize"
          instanceCenter = _instance.getCenter()
          _instance.setCenter that.center  if not floatEqual(instanceCenter.lat(), that.center.lat()) or not floatEqual(instanceCenter.lng(), that.center.lng())
          _instance.setZoom that.zoom  unless _instance.getZoom() is that.zoom

      @fit = ->
        if _instance and _markers.length
          bounds = new google.maps.LatLngBounds()
          angular.forEach _markers, (m, i) ->
            bounds.extend m.getPosition()

          _instance.fitBounds bounds

      @on = (event, handler) ->
        _handlers.push
          on: event
          handler: handler


      @addMarker = (lat, lng, icon, infoWindowContent, label, url, thumbnail) ->
        return  if that.findMarker(lat, lng)?
        marker = new google.maps.Marker(
          position: new google.maps.LatLng(lat, lng)
          map: _instance
          icon: icon
        )
        label
        url
        if infoWindowContent?
          infoWindow = new google.maps.InfoWindow(content: infoWindowContent)
          google.maps.event.addListener marker, "click", ->
            currentInfoWindow.close()  if currentInfoWindow?
            infoWindow.open _instance, marker
            currentInfoWindow = infoWindow

        
        # Cache marker 
        _markers.unshift marker
        
        # Cache instance of our marker for scope purposes
        that.markers.unshift
          lat: lat
          lng: lng
          draggable: false
          icon: icon
          infoWindowContent: infoWindowContent
          label: label
          url: url
          thumbnail: thumbnail

        
        # Return marker instance
        marker

      @findMarker = (lat, lng) ->
        i = 0

        while i < _markers.length
          pos = _markers[i].getPosition()
          return _markers[i]  if floatEqual(pos.lat(), lat) and floatEqual(pos.lng(), lng)
          i++
        null

      @findMarkerIndex = (lat, lng) ->
        i = 0

        while i < _markers.length
          pos = _markers[i].getPosition()
          return i  if floatEqual(pos.lat(), lat) and floatEqual(pos.lng(), lng)
          i++
        -1

      @addInfoWindow = (lat, lng, html) ->
        win = new google.maps.InfoWindow(
          content: html
          position: new google.maps.LatLng(lat, lng)
        )
        _windows.push win
        win

      @hasMarker = (lat, lng) ->
        that.findMarker(lat, lng) isnt null

      @getMarkerInstances = ->
        _markers

      @removeMarkers = (markerInstances) ->
        s = this
        angular.forEach markerInstances, (v, i) ->
          pos = v.getPosition()
          lat = pos.lat()
          lng = pos.lng()
          index = s.findMarkerIndex(lat, lng)
          
          # Remove from local arrays
          _markers.splice index, 1
          s.markers.splice index, 1
          
          # Remove from map
          v.setMap null

    _defaults =
      zoom: 8
      draggable: false
      container: null

    
    # Done
    PrivateMapModel()
  )
  
  # End model
  
  # Start Angular directive
  googleMapsModule = angular.module("google-maps", [])
  
  ###
  Map directive
  ###
  googleMapsModule.directive "googleMap", ["$log", "$timeout", "$filter", ($log, $timeout, $filter) ->
    controller = ($scope, $element) ->
      _m = $scope.map
      self.addInfoWindow = (lat, lng, content) ->
        _m.addInfoWindow lat, lng, content

    controller.$inject = ["$scope", "$element"]
    restrict: "EC"
    priority: 100
    transclude: true
    template: "<div class='angular-google-map' ng-transclude></div>"
    replace: false
    scope:
      center: "=center" # required
      markers: "=markers" # optional
      latitude: "=latitude" # required
      longitude: "=longitude" # required
      zoom: "=zoom" # required
      refresh: "&refresh" # optional
      windows: "=windows" # optional"

    controller: controller
    link: (scope, element, attrs, ctrl) ->
      
      # Center property must be specified and provide lat & 
      # lng properties
      if not angular.isDefined(scope.center) or (not angular.isDefined(scope.center.lat) or not angular.isDefined(scope.center.lng))
        $log.error "angular-google-maps: ould not find a valid center property"
        return
      unless angular.isDefined(scope.zoom)
        $log.error "angular-google-maps: map zoom property not set"
        return
      angular.element(element).addClass "angular-google-map"
      
      # Parse options
      opts = options: {}
      opts.options = angular.fromJson(attrs.options)  if attrs.options
      
      # Create our model
      _m = new MapModel(angular.extend(opts,
        container: element[0]
        center: new google.maps.LatLng(scope.center.lat, scope.center.lng)
        draggable: attrs.draggable is "true"
        zoom: scope.zoom
      ))
      _m.on "drag", ->
        c = _m.center
        $timeout ->
          scope.$apply (s) ->
            scope.center.lat = c.lat()
            scope.center.lng = c.lng()



      _m.on "zoom_changed", ->
        unless scope.zoom is _m.zoom
          $timeout ->
            scope.$apply (s) ->
              scope.zoom = _m.zoom



      _m.on "center_changed", ->
        c = _m.center
        $timeout ->
          scope.$apply (s) ->
            unless _m.dragging
              scope.center.lat = c.lat()
              scope.center.lng = c.lng()



      if attrs.markClick is "true"
        (->
          cm = null
          _m.on "click", (e) ->
            unless cm?
              cm =
                latitude: e.latLng.lat()
                longitude: e.latLng.lng()

              scope.markers.push cm
            else
              cm.latitude = e.latLng.lat()
              cm.longitude = e.latLng.lng()
            $timeout ->
              scope.latitude = cm.latitude
              scope.longitude = cm.longitude
              scope.$apply()


        )()
      
      # Put the map into the scope
      scope.map = _m
      
      # Check if we need to refresh the map
      if angular.isUndefined(scope.refresh())
        
        # No refresh property given; draw the map immediately
        _m.draw()
      else
        scope.$watch "refresh()", (newValue, oldValue) ->
          _m.draw()  if newValue and not oldValue

      
      # Markers
      scope.$watch "markers", ((newValue, oldValue) ->
        $timeout ->
          angular.forEach newValue, (v, i) ->
            _m.addMarker v.latitude, v.longitude, v.icon, v.infoWindow  unless _m.hasMarker(v.latitude, v.longitude)

          
          # Clear orphaned markers
          orphaned = []
          angular.forEach _m.getMarkerInstances(), (v, i) ->
            
            # Check our scope if a marker with equal latitude and longitude. 
            # If not found, then that marker has been removed form the scope.
            pos = v.getPosition()
            lat = pos.lat()
            lng = pos.lng()
            found = false
            
            # Test against each marker in the scope
            si = 0

            while si < scope.markers.length
              sm = scope.markers[si]
              
              # Map marker is present in scope too, don't remove
              found = true  if floatEqual(sm.latitude, lat) and floatEqual(sm.longitude, lng)
              si++
            
            # Marker in map has not been found in scope. Remove.
            orphaned.push v  unless found

          orphaned.length and _m.removeMarkers(orphaned)
          
          # Fit map when there are more than one marker. 
          # This will change the map center coordinates
          _m.fit()  if attrs.fit is "true" and newValue.length > 1

      ), true
      
      # Update map when center coordinates change
      scope.$watch "center", ((newValue, oldValue) ->
        return  if newValue is oldValue
        unless _m.dragging
          _m.center = new google.maps.LatLng(newValue.lat, newValue.lng)
          _m.draw()
      ), true
      scope.$watch "zoom", (newValue, oldValue) ->
        return  if newValue is oldValue
        _m.zoom = newValue
        _m.draw()

  ]
)()