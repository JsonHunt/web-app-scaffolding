@SignupController = ($scope,$ocModal,$http,$location) ->

	setTimeout ()->
		$('#username').focus()
	,100

	$scope.signup = ()->
		$http.post "/rest/pub/signup",
			user: $scope.user
		.error (data,status,headers,config)-> $scope.error = data
		.success (data,status,headers,config)->
			$ocModal.close()
			$location.path("/private/dupadupa.html")

@SignupController.$inject = [ '$scope','$ocModal','$http','$location' ]
