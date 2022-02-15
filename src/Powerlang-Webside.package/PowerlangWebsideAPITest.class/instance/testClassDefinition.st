code endpoints
testClassDefinition
	| definition |
	definition := self get: 'classes/Point'.
	self
		assert: definition name equals: 'Point';
		assert: (definition definition includesSubstring: 'x');
		assert: (definition definition includesSubstring: 'y')