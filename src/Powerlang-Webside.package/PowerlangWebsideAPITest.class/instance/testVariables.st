code endpoints
testVariables
	| variables |
	variables := self get: 'classes/Float/variables'.
	self assert: (variables anySatisfy: [ :v | v name = 'Infinity' ]).
	variables := self get: 'classes/Fraction/variables'.
	self
		assert: (variables anySatisfy: [ :v | v name = 'numerator' ]);
		assert: (variables anySatisfy: [ :v | v name = 'denominator' ])