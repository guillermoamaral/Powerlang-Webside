code endpoints
testClassVariables
	| variables |
	variables := self get: 'classes/Float/class-variables'.
	self assert: (variables anySatisfy: [ :v | v name = 'Infinity' ])