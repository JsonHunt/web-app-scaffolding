@LoginController = ($scope,$ocModal,$http,$modalInstance, $injector) ->

	setTimeout ()->
		$('#username').focus()
	,100

	$scope.login = ()->
		$http = $injector.invoke(($http) ->
			$http
		)
		$http.post 'rest/login',
			username: @username
			password: @password
		.error (data,status,headers,config)-> $scope.error = data
		.success (data,status,headers,config)->
			if data.error
				$scope.error = data.error
			else
				$modalInstance.close 'OK'

	$scope.passwordReset = ()->
		$ocModal.close()
		$ocModal.open
			id: 'modal2',
			url: 'password-reset/password-reset.html'
			controller: 'PasswordResetController'

@LoginController.$inject = [ '$scope','$ocModal','$http','$modalInstance','$injector' ]
