module.exports = SignupController = ($scope,$ocModal,$http) ->

	setTimeout ()->
		$('#username').focus()
	,100

	$scope.signup = ()->
		$http.post "/rest/signup",
			user: $scope.user
		.error (data,status,headers,config)-> $scope.error = data
		.success (data,status,headers,config)->
			if data.error
				$scope.error = data.error
			else
				$scope.sent = true

	$scope.close = ()->
		$ocModal.close()

SignupController.$inject = [ '$scope','$ocModal','$http']
