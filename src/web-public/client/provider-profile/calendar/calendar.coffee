module.exports = ['$scope', ($scope) ->

	$scope.weeks = []
	$scope.weekDays = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
	$scope.monthNames = ['January','February','March','April','May','June','July','August','September','October','November','December']

	$scope.today = new XDate()

	$scope.selectDay = (day)->
		if $scope.editing
			d = new XDate(day.date).getTime()
			a = $scope.person.availability
			if _.contains a, d
				_.remove a, (t)-> t is d
			else
				a.push d
			$scope.updateCalendar()


	$scope.prevMonth = ()->
		$scope.month--
		if $scope.month is -1
			$scope.month = 11
			$scope.year--
		$scope.updateCalendar()

	$scope.nextMonth = ()->
		$scope.month++
		if $scope.month is 12
			$scope.month = 0
			$scope.year++
		$scope.updateCalendar()

	$scope.updateCalendar = ()->
		firstDayOfMonth = new XDate($scope.year,$scope.month,1)
		current = new XDate(firstDayOfMonth).addDays(-firstDayOfMonth.getDay())

		for week in [0..5]
			$scope.weeks[week] =
				number: 1
				days: []
			for day in [0..6]
				isToday = Math.floor(current.diffDays($scope.today)) is 0
				isPast = current.diffDays($scope.today) >= 1
				# isSelected = $scope.selectedDate isnt undefined and Math.floor(current.diffDays($scope.selectedDate)) is 0
				isSelected = _.contains $scope.person.availability, current.getTime()

				$scope.weeks[week].days.push
					number: current.getDate()
					date: current.toDate()
					enabled: current.getMonth() is $scope.month or isPast
					today: isToday
					selected: isSelected
					past: isPast
				current.addDays(1)

	$scope.month = $scope.today.getMonth()
	$scope.year = $scope.today.getFullYear()
	$scope.updateCalendar()
]
