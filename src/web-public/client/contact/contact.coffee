module.exports = ['$scope', ($scope) ->
	$scope.gotoPage 'search'

	$scope.providerProfileController = require './../provider-profile/provider-profile'
	$scope.businessProfileController = require './../business-profile/business-profile'

	setTimeout ()->
		$('#location-search').focus()
	,100

	google.maps.event.addDomListener window, 'load', ()-> console.log "Maps loaded"
	setTimeout ()->
		canvas = document.getElementById('mapCanvas')
		mapOptions =
			center:
				lat: 0
				lng: 0
			zoom: 8

		$scope.geoCoder = new google.maps.Geocoder()
		$scope.map = new google.maps.Map(canvas,mapOptions)

		if navigator.geolocation
			navigator.geolocation.getCurrentPosition (position)->
				console.log JSON.stringify position
				userLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude)
				$scope.geoCoder.geocode {location: userLocation}, (results, status)->
					console.log status
					console.log JSON.stringify results[0]
					for place in results
						if (_.contains place.types, 'country') and (place.geometry?.viewport isnt undefined)
							$scope.map.fitBounds place.geometry.viewport
							$scope.loadCirclesForPlace place
	,0

	$scope.search =
		places: undefined

	$scope.$watch 'search.places', (place)->
		return if place is undefined or place.geometry is undefined
		if place.geometry.viewport
			$scope.map.fitBounds place.geometry.viewport
			$scope.map.panToBounds place.geometry.viewport
		else if place.geometry.location
			$scope.map.panTo place.geometry.location
			$scope.map.setZoom 12

		if place.geometry.location
			$scope.area = place.formatted_address
			$scope.loadCirclesForPlace place


	$scope.onMarkerClick = ()->
		$scope.page = 'provider-profile'

	$scope.circles = []

	$scope.loadCirclesForPlace = (place)->
		for c in $scope.circles
			c.setMap(null)

		circle = new google.maps.Circle(
			center: place.geometry.location
			radius: 1000
			map: $scope.map
			strokeWeight: 0,
			fillColor: '#e18882',
			fillOpacity: 0.4,
			click: (event)->
		)
		$scope.circles.push circle
		google.maps.event.addListener circle, 'click', (event)->
			$scope.$apply ()->
				$scope.area = place.formatted_address




	# $scope.onPlaceSearch = ()->

	# $scope.map =
	# 	center:
	# 		latitude: 36.4501508
	# 		longitude: 14.6057925
	# 	zoom: 2
	#
	# $scope.searchbox =
	# 	template:'searchbox.tpl.html'
	# 	events:
	# 		places_changed: (searchBox)->
	# 			console.log "Place was selected"
	# 			places = searchBox.getPlaces()
	# 			if places.length > 0
	# 				location = places[0].geometry.location
	# 				viewport = places[0].geometry.viewport
	# 				ne = viewport.getNorthEast()
	# 				sw = viewport.getSouthWest()

					# bounds = new google.maps.GLatLngBounds(
					# 	new google.maps.GLatLng(sw.lat(), sw.lng())
					# 	new google.maps.GLatLng(ne.lat(), ne.lng())
					# )

					# $scope.maps.Map.fitBounds(bounds)
					# $scope.map.center.latitude = location.lat()
					# $scope.map.center.longitude = location.lng()

					#
					# $scope.map.bounds =
					# 	northeast:
					# 		latitude: ne.lat()
					# 		longitude: ne.lng()
					# 	southwest:
					# 		latitude: sw.lat()
					# 		longitude: sw.lng()


	# uiGmapGoogleMapApi.then (maps)->
	# 	console.log "Maps is available"
	# 	$scope.maps = maps


]
