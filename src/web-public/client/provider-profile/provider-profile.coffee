module.exports = ['$scope','FileUploader', ($scope,FileUploader) ->
	$scope.calendarController = require './calendar/calendar'

	$scope.person =
		name: "Kasia"
		title: "Profesjonalna dupencja"
		# location: "Mokotow, Warszawa, Polska"
		description: "24 lata, fajna dupa ze mnie"
		contacts: [
			{type:'Email',value:'kasia@serveus.com'}
			{type:'Telefon',value:'000 000 0000'}
		]
		services: [
			{name:'Cleaning'}
			{name:'Ironing'}
			{name:'Babysitting'}
			{name:'Shovelling snow'}
		]
		prices: [
			{name: 'Godzina u ciebie', value: '200 zl'}
			{name: 'Godzina u mnie', value: '200 zl'}
			{name: 'Lodziak', value: '+50 zl'}
		]
		hours: [
			{name: 'Poniedzialek', value: '23:00 - 8:00'}
			{name: 'Wtorek', value: '23:00 - 8:00'}
			{name: 'Sroda', value: '23:00 - 8:00'}
			{name: 'Czwartek', value: '23:00 - 8:00'}
			{name: 'Piatek', value: '23:00 - 8:00'}
			{name: 'Sobota', value: '23:00 - 8:00'}
		]
		availability: [
			new XDate(2015,4,10).getTime()
			new XDate(2015,4,11).getTime()
			new XDate(2015,4,13).getTime()
			new XDate(2015,4,14).getTime()
		]
		pictures: []

	$scope.save = ()->
		$scope.toggleEdit()

	$scope.toggleEdit = ()->
		$scope.editing = !$scope.editing
		if $scope.editing and $scope.person.location
			$scope.search.places = $scope.person.location.name

	$scope.newContact = ->
		$scope.person.contacts.push {}

	$scope.deleteContact = (c,index)->
		$scope.person.contacts.splice index,1

	$scope.newService = ->
		$scope.person.services.push {}

	$scope.deleteService = (s,index)->
		$scope.person.services.splice index,1

	$scope.newPrice = ->
		$scope.person.prices.push {}

	$scope.deletePrice = (p,index)->
		$scope.person.prices.splice index,1

	$scope.newHour = ->
		$scope.person.hours.push {}

	$scope.deleteHour = (p,index)->
		$scope.person.hours.splice index,1

	setTimeout ()->
		$('#location-search').focus()
	,100

	#  IMAGE UPLOAD

	uploader = $scope.uploader = new FileUploader
	uploader.scope = $scope
	uploader.url = 'rest/uploadGraphic'
	# uploader.formData = [ {
	# 	action: 'uploadGraphic'
	# 	projectID: '123'
	# } ]

	uploader.onAfterAddingFile = (event, item) ->
		$scope.uploader.uploadAll()

	uploader.onSuccessItem = (item,response,status,headers) ->
		if response.result == 'success'
			photo =
				url: "graphic/#{response.file}"
			$scope.person.pictures.push photo

	# MAP AND LOCATION

	google.maps.event.addDomListener window, 'load', ()-> console.log "Maps loaded"

	$scope.geoCoder = new google.maps.Geocoder()

	setTimeout ()->
		canvas = document.getElementById('locationCanvas')
		mapOptions =
			center:
				lat: 0
				lng: 0
			zoom: 8
		$scope.map = new google.maps.Map(canvas,mapOptions)
	,0


		# google.maps.event.addListener $scope.map, 'click', (ev)->
		# 	return if not $scope.editing
		# 	$scope.map.panTo(ev.latLng)
		# 	$scope.$apply ()->
		# 		$scope.person.location = ev.latLng
		# 	if $scope.locationMarker
		# 		$scope.locationMarker.setMap(null)
		# 	$scope.locationMarker = new google.maps.Marker
		# 			position: ev.latLng
		# 			map: $scope.map
		# 			title: 'Twoja lokacja'
		# 	$scope.geoCoder.geocode {location: ev.latLng}, (results, status)->
		# 		for place in results
		# 			if _.contains place.types, 'neighborhood'
		# 				$scope.$apply ()->
		# 					$scope.person.locationName = place.formatted_address
		# 					vp = place.geometry.location
		# 					vp = place.geometry.viewport if vp is undefined
		# 					$scope.map.fitBounds(vp)
		# 					lat = ev.latLng.lat()
		# 					lng = ev.latLng.lng()
		# 					zoom = $scope.map.getZoom()
		# 					$scope.person.locationURL = "https://maps.googleapis.com/maps/api/staticmap?center=-#{lat},#{lng}&zoom=#{zoom}"

		# if $scope.person.location
		# 	# if $scope.locationMarker
		# 	# 	$scope.locationMarker.setMap(null)
		# 	# $scope.locationMarker = new google.maps.Marker({
		# 	# 		position: $scope.person.location
		# 	# 		map: $scope.map
		# 	# 		title: 'Twoja lokacja'
		# 	# });
		# 	$scope.map.fitBounds($scope.person.location.viewport)


		# else if navigator.geolocation
		# 	navigator.geolocation.getCurrentPosition (position)->
		# 		console.log JSON.stringify position
		# 		userLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude)
		# 		$scope.geoCoder.geocode {location: userLocation}, (results, status)->
		# 			for place in results
		# 				if _.contains place.types, 'neighborhood'
		# 					if place.geometry?.viewport isnt undefined
		# 						$scope.map.fitBounds(place.geometry.viewport)
		# 						return
	# ,0

	$scope.getMapURL = ->
		return undefined if $scope.person.location is undefined
		width = $("#location-bar").outerWidth()

		"https://maps.googleapis.com/maps/api/staticmap?center=#{$scope.person.location.name}&size=#{width}x200"

	$scope.search =
		places: undefined

	$scope.$watch 'search.places', (place)->
		return if place is undefined or place.geometry is undefined
		# $scope.map.fitBounds place.geometry.viewport
		# $scope.$apply ()->
		# setTimeout ()->
		# 	$scope.$apply ()->
		$scope.person.location =
			name: place.formatted_address
			lat: place.geometry.location.lat()
			lng: place.geometry.location.lng()
		# ,100
]
