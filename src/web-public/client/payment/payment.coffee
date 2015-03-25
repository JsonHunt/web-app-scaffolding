module.exports = PaymentController = ($scope, $http, $modalInstance) ->

	setTimeout ()->
		$('.amount').focus()
	,100

	$scope.pay = ()->
		if not $scope.payment?.amount or $scope.payment?.amount.length is 0
			$scope.error = "Amount is required"
			return

		if isNaN($scope.payment.amount)
			$scope.error = "Amount must be a number"
			return

		delete $scope.error
		handler = StripeCheckout.configure
			key: 'pk_test_6pRNASCoBOKtIshFeQd4XMUh'
			image: '/img/documentation/checkout/marketplace.png'
			token: (token)->
				$http.post "/rest/payment",
					token: token
				.success (data,status,headers,config)->
					$scope.error = data.error
					if not $scope.error
						$scope.confirmed = true

				.error (data,status,headers,config)->
					$scope.error = data
			# // Use the token to create the charge with a server-side script.
			# // You can access the token ID with `token.id`

		handler.open
			name: 'Webapp',
			description: 'Webapp subscription',
			amount: $scope.payment.amount*100

	$scope.cancel = ()->
		$modalInstance.close()

	$scope.close = ()->
		$modalInstance.close()

PaymentController.$inject = [ '$scope', '$http', '$modalInstance' ]
