code endpoints
testAccessors
	| accessors |
	accessors := self get: 'methods?class=Fraction&referencing=numerator'.
	self
		assert: accessors notEmpty;
		assert:
			(accessors
				allSatisfy: [ :m | m source includesSubstring: 'numerator' ]).
	accessors := self get: 'methods?class=Fraction&assigning=numerator'.
	self
		assert: accessors notEmpty;
		assert:
			(accessors
				allSatisfy: [ :m | m source includesSubstring: 'numerator :=' ])