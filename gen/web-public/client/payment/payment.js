// Generated by CoffeeScript 1.9.1
(function() {
  var PaymentController;

  module.exports = PaymentController = function($scope, $http, $modalInstance) {
    setTimeout(function() {
      return $('.amount').focus();
    }, 100);
    $scope.dopay = function() {
      var handler;
      if (!this.amount || this.amount.length === 0) {
        $scope.error = "Amount is required";
        return;
      }
      if (isNaN(this.amount)) {
        $scope.error = "Amount must be a number";
        return;
      }
      delete $scope.error;
      handler = StripeCheckout.configure({
        key: 'pk_test_6pRNASCoBOKtIshFeQd4XMUh',
        image: '/img/documentation/checkout/marketplace.png',
        token: function(token) {
          return $http.post("/rest/payment", {
            token: token
          }).success(function(data, status, headers, config) {
            $scope.error = data.error;
            if (!$scope.error) {
              return $scope.confirmed = true;
            }
          }).error(function(data, status, headers, config) {
            return $scope.error = data;
          });
        }
      });
      handler.open({
        name: 'Webapp',
        description: 'Webapp subscription',
        amount: this.amount * 100
      });
      return $scope.wait = true;
    };
    $scope.cancel = function() {
      return $modalInstance.close();
    };
    return $scope.close = function() {
      return $modalInstance.close();
    };
  };

  PaymentController.$inject = ['$scope', '$http', '$modalInstance'];

}).call(this);
