@RegisterController = ($scope,$http,$location)->
	
	$scope.register = ()->
		$http.post "http://localhost:3000/messaging/register",
			login: $scope.login
			password: $scope.password
		.success (data,status,headers,config)->
			if data.status is 'ok'
				window.user = data.user
				$location.path 'websites'	
			if data.status is 'error'
				$scope.message = data.message	

	$scope.registration = ()->
		$location.path 'register'
    
@RegisterController.$inject = [ '$scope','$http','$location' ]

angular.module('Dating').controller('RegisterController', RegisterController)