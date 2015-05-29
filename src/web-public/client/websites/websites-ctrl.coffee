@WebsitesController = ($scope,$http,$location)->
	
	if window.user is undefined
		$location.path ''
	else 
		$scope.sa = window.user.websiteProfiles['sa']
		$scope.pof = window.user.websiteProfiles['pof']

		$scope.sa ?= {}
		$scope.pof ?= {}
		$scope.sa.save = ()-> 
			$http.post "http://localhost:3000/messaging/saveWebsiteSettings",
				website: 'sa'
				userID: window.user._id
				settings: @settings
			.success (data,status,headers,config)->
				$scope.sa.message = data

		$scope.pof.save = ()-> 
			$http.post "http://localhost:3000/messaging/saveWebsiteSettings",
				website: 'pof'
				userID: window.user._id
				settings: @settings
			.success (data,status,headers,config)->
				$scope.pof.message = data

    
@WebsitesController.$inject = [ '$scope','$http','$location' ]

angular.module('Dating').controller('WebsitesController', WebsitesController)