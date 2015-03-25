module.exports = ChangePasswordController = ($scope, $http, $location) ->

	$scope.changePassword = ()->
		if !$scope.newpass or $scope.newpass.length is 0
			$scope.error = "Password is required"
			return

		if $scope.newpass isnt $scope.newpass2
			$scope.error = "Passwords don't match"
			return

		$http.post "/rest/changePassword",
			password: $scope.newpass
		.error (data,status,headers,config)-> $scope.error = data
		.success (data,status,headers,config)->
			$scope.error = data.error
			if !$scope.error
				$scope.changed = true

	$scope.cancel = ()->
		$location.path("/")


ChangePasswordController.$inject = [ '$scope', '$http', '$location' ]
# module.exports = ChangePasswordController
