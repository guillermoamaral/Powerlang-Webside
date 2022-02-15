code endpoints
testInstanceVariables
	| variables |
	variables := self get: 'classes/Fraction/instance-variables'.
	self
		assert: (variables anySatisfy: [ :v | v name = 'numerator' ]);
		assert: (variables anySatisfy: [ :v | v name = 'denominator' ])