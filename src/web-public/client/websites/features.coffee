module.exports = FeaturesController = ($scope,$http) ->
	$http.post "/rest/getPrivateUserData"
	.success (data,status,headers,config)->
		$scope.data = data.data
		$scope.error = data.error
	.error (data,status,headers,config)->
		$scope.error = data


FeaturesController.$inject = [ '$scope','$http' ]
