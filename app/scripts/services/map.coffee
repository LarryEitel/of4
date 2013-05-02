'use strict';
class GMarker
    constructor: (@map, @lat, @lng) ->
        @position = new google.maps.LatLng(@lat, @lng)
        @render()

    render: ->
        @marker = new google.maps.Marker(
            draggable: true
        )

        google.maps.event.addListener @marker, "dragend", @dragend
        google.maps.event.addListener @marker, "click", @click

        @show()

    dragend: =>
        if confirm("Are you sure you want to move this marker?")
            # @model.set(lat:  @marker.position.lat(), lng: @marker.position.lng())
            # @model.save()
        else
            # move back to original position
            # @marker.setPosition( new google.maps.LatLng(@model.get('lat'), @model.get('lng')))

    show: =>
        @marker.setPosition(@position)

        # title = ''
        # @marker.setTitle(title)
        @marker.setMap(@map)

#  click: =>
#    infoWindow = new InfoWindow()
#
#    # testing
#    $('a#place-item-move.btn').live 'click', (event) ->
#      #console.log 'event', event
#      #event.preventDefault()
#      console.log 'place-item-move'
#
#
#    infoWindow.self.open(@map, @marker)


    move: (event) =>
        console.log 'move'
        event.preventDefault()
        alert 'move'

class GMap
    constructor: (options) ->
        # TODO: What is method to loop through option attribs and assign to @/this?
        @rootScope = options.rootScope
        @dragging = 0
        # user id dragging map
        @location = options.location
        @positionTracking = off

        # check for lat/lng, zoom, maptype on url
        q               = @location.search().q
        if q
            ll            = q.split(',')
            lat           = ll[0]
            lng           = ll[1]
            @center =
            {lat: lat, lng: lng}
            # console.log 'center q:' + @center
        else
            @center = options.center


        @zoom = parseInt(@location.search().z) || options.zoom
        @mapType = @location.search().t || options.mapType

        @navBarHeight = @rootScope.navBarHeight

        @win = $(window)
        @crossHairLatEl = $('#mapcrosshairlat')
        @crossHairLngEl = $('#mapcrosshairlng')
        @mapEl = $("#map")
        @mapTypes =
        {m: 'roadmap', h: 'hybrid'}

        mapTypeControl: true
        mapTypeControlOptions:
            style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
            position: google.maps.ControlPosition.TOP_RIGHT
            mapTypeIds: [google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.HYBRID]

        panControl: false
        panControlOptions:
            position: google.maps.ControlPosition.TOP_RIGHT

        streetViewControl: false
        streetViewControlOptions:
            position: google.maps.ControlPosition.LEFT_TOP

        zoomControl: true
        zoomControlOptions:
            style: google.maps.ZoomControlStyle.LARGE
            position: google.maps.ControlPosition.LEFT_TOP

        @mapEl.hide()

        # resize mapEl div when window is initialize
        @resizeMapEl()

        # resize mapEl div when window is resized
        @win.resize @resizeMapEl
        $('#map-position-button').click @onPositionButtonClick
        $('#map-add-button').click(@addPlace)

        # this will be moved to GMarker
        $('#map-directions-button').click(@getDirections)

        @map = new google.maps.Map(@mapEl[0], {
                zoom: @zoom
                center: new google.maps.LatLng(@center.lat, @center.lng)
                mapTypeId: @mapTypes[@mapType]
            })

        addListener     = google.maps.event.addListener
        addListener @map, 'center_changed', @onCenterChanged
        addListener @map, 'maptypeid_changed', @onTypeChange
        addListener @map, 'zoom_changed', @onZoomChange
        addListener @map, 'dragstart', @onDragStart
        addListener @map, 'dragend', @onDragEnd

        @rootScope.protocol = @location.protocol()
        @rootScope.host = @location.host()
        @rootScope.mapCenter = @center
        @rootScope.mapZoom = @zoom
        @rootScope.mapType = @mapType

        @updateLocation()


    getDirections: =>
        console.log 'getDirections'

    addPlace: =>
        #if confirm("Add a new place?")
        lat = @map.getCenter().lat()
        lng = @map.getCenter().lng()
        #console.log lat, lng
        marker = new GMarker(@map, lat, lng)
    # @places.create(territoryno: @preferences.get('territoryno'), point: "POINT (#{lat} #{lng})")




    onPositionButtonClick: =>
        if !@positionTracking.state
            @positionTrackingOn()
            @positionTrackGoTo()

        else if @positionTracking.state
            @cancelPositionTracking()

    positionTrackingOn: ->
        if not @nav
            @nav = window.navigator

        if @nav
            geoLoc = @nav.geolocation
            window.map = @map

            if geoLoc
                watchID = geoLoc.watchPosition(geoSuccessCallback, geolocationError, options =
                {enableHighAccuracy: true})

            try
                geoLoc.getCurrentPosition(geoSuccessCallback, geolocationError, options =
                {enableHighAccuracy: true})

            @positionTracking.state = true


    positionTrackGoTo: ->
        pos = window.pos
        if pos
            @map.setCenter(new google.maps.LatLng(pos.lat(), pos.lng()))

    cancelPositionTracking: (watchID) ->
        window.navigator.geolocation.clearWatch(watchID)
        try
            window.userPositionMarker.setMap(null)

        @positionTracking.state = false

    geoSuccessCallback = (position) =>
        if position.coords.latitude
            window.pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)

            try
                window.userPositionMarker.setMap(null)

            icon = 'images/blue-dot.png'
            # purpose is to center marker in crosshair
            image = new google.maps.MarkerImage(icon,
                new google.maps.Size(16, 16),
                new google.maps.Point(0, 0),
                new google.maps.Point(8, 3))

            window.userPositionMarker = new google.maps.Marker(
                icon: image
                position: window.pos
                # want to center on the user position initially
                # but allow user to pan around without map auto centering
                map: window.map
                title: 'You are here.'
            )

    geolocationError = (error) ->
        # This needs testing
        console.log 'geoLoc error'
        msg = 'Unable to locate position. '
        switch error.code
            when error.TIMEOUT then msg += 'Timeout.'
            when error.POSITION_UNAVAILABLE then msg += 'Position unavailable.'
            when error.PERMISSION_DENIED then msg += 'Please turn on location services.'
            when error.UNKNOWN_ERROR then msg += error.code


        $('.alert-message').remove()
        alert = $('<div class="alert-message error fade in" data-alert="alert">')
        alert.html('<a class="close" href="#">×</a>' + msg);
        alert.insertBefore($('.span10'))


    updateLocation: ->
        @location.url("/")
        # @location.url("/map?q=#{@center.lat},#{@center.lng}&t=#{@mapType}&z=#{@zoom}")

    onDragStart: =>
        @dragging = on

    onDragEnd: =>
        @dragging = off
        @onCenterChanged()

    resizeMapEl: =>
        @mapEl.css('height', (@win.height() - @navBarHeight))

    onCenterChanged: =>
        center                = @map.getCenter()
        @center.lat = center.lat()
        @center.lng = center.lng()
        @crossHairLatEl.html(@center.lat)
        @crossHairLngEl.html(@center.lng)

        if not @dragging
            @rootScope.mapCenter = @center
            @rootScope.$apply()

            @updateLocation()

    onZoomChange: =>
        @rootScope.mapZoom = @zoom = @map.getZoom()
        @rootScope.$apply()
        @updateLocation()

    onTypeChange: =>
        @mapType = @map.getMapTypeId()

        #TODO LWE: add polyOpts
        switch @map.getMapTypeId()
            when google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.HYBRID
                @polyOpts = true # @roadmapPolyOpts
            else
                @polyOpts = true
        # @hybridPolyOpts

        @rootScope.mapType = @mapType[0]
        @rootScope.$apply()
        @updateLocation()

angular.module('of4App')
    .factory "GoogleMap", ($rootScope, $location) ->
        SJO                     = {lat: 9.993552791991132, lng: -84.20888416469096}
        initPosition            = SJO
        initZoom                = 16

        mapOptions =
            rootScope: $rootScope
            location: $location
            zoom: initZoom
            mapType: 'm'
            center:
                lat: initPosition.lat
                lng: initPosition.lng

        return new GMap(mapOptions)