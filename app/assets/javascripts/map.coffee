$ ->
  initialize()

colors = ['#FF0000', '#00FF00', '#0000FF', '#ffff00', '#00ffff']

initialize = ->
  mapOptions =
    center:
      lat: 39.73931800000005
      lng: -89.50413899999998
    zoom: 8

  map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)

  loadData(map)

loadData = (map) ->
  $.getJSON '/house.geojson', (data) ->
    color_index = 0
    for feature in data.features
      console.log color_index
      addDistrict(map, feature, colors[color_index])
      color_index++
      if color_index > (colors.length - 1)
        color_index = 0


addDistrict = (map, feature, color) ->

  districtCoords = []
  for coords in feature.geometry.coordinates[0]
    districtCoords.push new google.maps.LatLng(coords[1], coords[0])

  district = new google.maps.Polygon
    paths: districtCoords
    strokeColor: color
    strokeOpacity: 0.8
    strokeWeight: 2
    fillColor: color
    fillOpacity: 0.35
    districtID: feature.properties.District_N

  district.setMap(map)
  addListenersOnPolygon(district)

addListenersOnPolygon = (polygon) ->
  google.maps.event.addListener polygon, 'click', (event) ->
    alert this.districtID
