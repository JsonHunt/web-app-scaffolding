@LoginController = ($scope,$ocModal,$http) ->

		$scope.login = ()->
			$http.post "/login",
				username: $scope.username
				password: $scope.password
			.error (data,status,headers,config)-> $scope.error = data
			.success (data,status,headers,config)->
				

@LoginController.$inject = [ '$scope','$ocModal','$http' ]
