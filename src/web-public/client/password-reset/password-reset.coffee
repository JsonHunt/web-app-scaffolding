@PasswordResetController = ($scope, $http, $ocModal) ->

	setTimeout ()->
		$('.focusme').focus()
	,100

	$scope.resetContinue = ()->
		$http.post "/rest/requestPasswordReset",
			email: $scope.email
		.success (data,status,headers,config)->
			$scope.error = data.error
			if !data.error
				$scope.sent = true
		.error (data,status,headers,config)-> $scope.error = data

	$scope.close = ()->
		$ocModal.close()

	$scope.resetCancel = ()->
		$ocModal.close()

@PasswordResetController.$inject = [ '$scope', '$http','$ocModal' ]
