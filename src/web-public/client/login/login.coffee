@LoginController = ($scope,$ocModal,$http) ->

	setTimeout ()->
		$('#username').focus()
	,100

	$scope.login = ()->
		$http.post "/rest/pub/login",
			username: $scope.username
			password: $scope.password
		.error (data,status,headers,config)-> $scope.error = data
		.success (data,status,headers,config)->
			$ocModal.close()
			$scope.goto('/private')

@LoginController.$inject = [ '$scope','$ocModal','$http' ]
