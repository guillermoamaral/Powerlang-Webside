code endpoints
testSubclasses
	| subclasses |
	subclasses := self get: 'classes/Magnitude/subclasses'.
	self
		assert: (subclasses anySatisfy: [ :c | c name = 'Time' ]);
		assert: (subclasses anySatisfy: [ :c | c name = 'Number' ])