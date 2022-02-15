code endpoints
testMethod
	| method |
	method := self get: 'classes/Point/methods/x'.
	self
		assert: method selector equals: 'x';
		assert:
			((method source includesSubstring: '^x')
				or: [ method source includesSubstring: '^ x' ])