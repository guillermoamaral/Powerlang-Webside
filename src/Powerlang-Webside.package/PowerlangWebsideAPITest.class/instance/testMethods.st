code endpoints
testMethods
	| methods |
	methods := self get: 'classes/Point/methods'.
	self
		assert: methods notEmpty;
		assert: (methods allSatisfy: [ :m | (m at: 'class') = 'Point' ])