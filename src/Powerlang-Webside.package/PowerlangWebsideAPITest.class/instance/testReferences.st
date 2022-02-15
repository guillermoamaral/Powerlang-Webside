code endpoints
testReferences
	| references |
	references := self get: 'methods?referencing=Fraction'.
	self
		assert: references notEmpty;
		assert:
			(references
				allSatisfy: [ :m | m source includesSubstring: 'Fraction' ])