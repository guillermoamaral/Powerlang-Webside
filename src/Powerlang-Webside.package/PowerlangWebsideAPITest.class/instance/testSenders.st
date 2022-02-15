code endpoints
testSenders
	| senders local |
	senders := self get: 'methods?sending=reciprocal'.
	self
		assert: senders notEmpty;
		assert: (senders allSatisfy: [ :m | m source includesSubstring: 'reciprocal' ]);
		assert: (senders anySatisfy: [ :m | (m at: 'class') = 'Fraction' ]).
	local := self get: 'methods?sending=reciprocal&class=Fraction'.
	self
		assert: local notEmpty;
		assert: (local allSatisfy: [ :m | m source includesSubstring: ' reciprocal' ]);
		assert: (local allSatisfy: [ :m | (m at: 'class') = 'Fraction' ])