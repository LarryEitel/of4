# See: http://developers.cartodb.com/examples/editing-polygons.html
# Pick a random lat & lng at the start
drawPolygon = (id, poly) ->
  
  # Construct the polygon
  # Note that we don't specify an array or arrays, but instead just
  # a simple array of LatLngs in the paths property
  options =
    paths: poly
    strokeColor: "#AA2143"
    strokeOpacity: 1
    strokeWeight: 2
    fillColor: "#FF6600"
    fillOpacity: 0.7

  newPoly = new google.maps.Polygon(options)
  newPoly.cartodb_id = id
  newPoly.setMap map
  google.maps.event.addListener newPoly, "click", ->
    @setEditable true
    setSelection this

  polys.push newPoly
getPolygons = ->
  url = "http://" + user + ".cartodb.com/api/v1/sql?q=" + query
  $.getJSON url, (response) ->
    for i of response.rows
      coords = JSON.parse(response.rows[i].geoj).coordinates[0][0]
      poly = new Array()
      for j of coords
        poly.push new google.maps.LatLng(coords[j][1], coords[j][0])
      poly.pop()
      drawPolygon response.rows[i].cartodb_id, poly

clearSelection = ->
  return  unless selectedShape
  storePolygon selectedShape.getPath(), selectedShape.cartodb_id
  selectedShape.setEditable false
  selectedShape = null
setSelection = (shape) ->
  clearSelection()
  selectedShape = shape
  shape.setEditable true
overlay = undefined
image = undefined
selectedShape = undefined
polys = new Array()
auth = false
map = null
status = "Ia"
lat = -6 + Math.floor(Math.random() * 5)
lng = 110 + Math.floor(Math.random() * 12)
zoom = 6
user = "examples"
table = "write_polygons"
query = "SELECT cartodb_id, ST_AsGeoJSON(the_geom) as geoj FROM " + table + " ORDER BY updated_at DESC LIMIT 25"
storePolygon = (path, cartodb_id) ->
  coords = new Array()
  payload =
    type: "MultiPolygon"
    coordinates: new Array()

  payload.coordinates.push new Array()
  payload.coordinates[0].push new Array()
  i = 0

  while i < path.length
    coord = path.getAt(i)
    coords.push coord.lng() + " " + coord.lat()
    payload.coordinates[0][0].push [coord.lng(), coord.lat()]
    i++
  q = "geojson=" + JSON.stringify(payload)
  q = q + "&cartodb_id=" + cartodb_id  if cartodb_id
  $.ajax
    url: "http://cartodb-gallery.appspot.com/cartodb/write/polygon"
    crossDomain: true
    type: "POST"
    dataType: "jsonp"
    data: q
    success: ->

    error: ->


$ ->
  
  #Basic
  cartodbMapOptions =
    zoom: zoom
    center: new google.maps.LatLng(lat, lng)
    disableDefaultUI: true
    mapTypeId: google.maps.MapTypeId.ROADMAP

  
  # Init the map
  map = new google.maps.Map(document.getElementById("map"), cartodbMapOptions)
  
  # Define the map styles (optional)
  mapStyle = [
    stylers: [
      saturation: -65
    ,
      gamma: 1.52
    ]
  ,
    featureType: "administrative"
    stylers: [
      saturation: -95
    ,
      gamma: 2.26
    ]
  ,
    featureType: "water"
    elementType: "labels"
    stylers: [visibility: "off"]
  ,
    featureType: "administrative.locality"
    stylers: [visibility: "off"]
  ,
    featureType: "road"
    stylers: [
      visibility: "simplified"
    ,
      saturation: -99
    ,
      gamma: 2.22
    ]
  ,
    featureType: "poi"
    elementType: "labels"
    stylers: [visibility: "off"]
  ,
    featureType: "road.arterial"
    stylers: [visibility: "off"]
  ,
    featureType: "road.local"
    elementType: "labels"
    stylers: [visibility: "off"]
  ,
    featureType: "transit"
    stylers: [visibility: "off"]
  ,
    featureType: "road"
    elementType: "labels"
    stylers: [visibility: "off"]
  ,
    featureType: "poi"
    stylers: [saturation: -55]
  ]
  map.setOptions styles: mapStyle
  getPolygons()
  drawingManager = new google.maps.drawing.DrawingManager(
    drawingControl: true
    drawingControlOptions:
      position: google.maps.ControlPosition.TOP_RIGHT
      drawingModes: [google.maps.drawing.OverlayType.POLYGON]

    polygonOptions:
      fillColor: "#0099FF"
      fillOpacity: 0.7
      strokeColor: "#AA2143"
      strokeWeight: 2
      clickable: true
      zIndex: 1
      editable: true
  )
  drawingManager.setMap map
  google.maps.event.addListener drawingManager, "overlaycomplete", (e) ->
    
    # Add an event listener that selects the newly-drawn shape when the user
    # mouses down on it.
    newShape = e.overlay
    newShape.type = e.type
    google.maps.event.addListener newShape, "click", ->
      setSelection this

    setSelection newShape
    storePolygon newShape.getPath()
    newShape.setEditable false

  google.maps.event.addListener map, "click", clearSelection
