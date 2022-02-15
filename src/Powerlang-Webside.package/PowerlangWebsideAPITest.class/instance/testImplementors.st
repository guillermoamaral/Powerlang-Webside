code endpoints
testImplementors
	| implementors local |
	implementors := self get: 'methods?selector=reciprocal'.
	self
		assert: implementors notEmpty;
		assert: (implementors allSatisfy: [ :m | m selector = 'reciprocal' ]);
		assert: (implementors anySatisfy: [ :m | (m at: 'class') = 'Fraction' ]).
	local := self get: 'methods?selector=reciprocal&class=Fraction'.
	self
		assert: local notEmpty;
		assert: (local allSatisfy: [ :m | m selector = 'reciprocal' ]);
		assert: (local allSatisfy: [ :m | (m at: 'class') = 'Fraction' ])