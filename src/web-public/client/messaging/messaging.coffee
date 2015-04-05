# This screen shows conversations with all profiles that user hasn't responded to
module.exports = MessageReaderController = ($scope,$http,$interval)->

	$scope.filterMembersByLocation = ()->
		if ($scope.settings.locationFilter)
			$scope.settings.location ?= ''
			allowedLocations = $scope.settings.locations.toLowerCase().split(' ')
			$scope.members = _.filter $scope.allMembers, (m)->
				words = m.location?.toLowerCase().split(///[\s,;]///)
				common = _.intersection allowedLocations,words
				return common.length > 0
		else
			$scope.members = $scope.allMembers

	$scope.getProfilesToRespond = ()->
		$http.get "http://localhost:3000/messaging/getProfilesToRespond"
		.success (data,status,headers,config)->
			if data.status is 'ok'
				$scope.allMembers = _.sortBy data.profiles, (member)-> member.id
				$scope.filterMembersByLocation()
			else if data.status is 'error'
				$scope.message = data.message
				$interval.cancel window.checkInboxTimer
			# for m in $scope.members
			# 	m.messages = _.sortBy m.messages, (msg)-> msg.sequence


	$scope.respond = (member)->
		$http.post "http://localhost:3000/messaging/sendMessage/#{member.website}/#{member.id}",
			message: $scope.response[member.id]
		.success (data,status,headers,config)->
			$scope.members = _.filter $scope.members, (m)-> m.id != member.id

	$scope.block = (member)->
		$http.get "http://localhost:3000/messaging/blockProfile/#{member.website}/#{member.id}"
		.success (data,status,headers,config)->
			$scope.members = _.filter $scope.members, (m)-> m.id != member.id

	$scope.saveSettings = ()->
		$http.post "http://localhost:3000/messaging/setSettings",
			locations: $scope.settings.locations
			locationFilter: $scope.settings.locationFilter


	if window.user is undefined
		$location.path ''
	else
		window.response ?= {}
		$scope.response = window.response
		$scope.settings = window.user.settings

		$scope.getProfilesToRespond()
		window.checkInboxTimer = $interval ()=>
			$scope.getProfilesToRespond()
		,30000

		$scope.$on "$destroy", ()->
					$interval.cancel window.checkInboxTimer


MessageReaderController.$inject = [ '$scope','$http','$interval' ]
