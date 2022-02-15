changes endpoints
testMethodDefinition
	| change method |
	change := NeoJSONObject new
		at: 'type' put: 'MethodDefinition';
		at: 'class' put: 'Point';
		at: 'category' put: self class name;
		at: 'sourceCode'
			put:
			'testMethodDefinition
	^x + 1';
		at: 'author' put: self class name;
		yourself.
	[ self post: '/changes' with: change.
	method := self get: '/classes/Point/methods/testMethodDefinition'.
	self
		assert: method notNil;
		assert: method selector equals: 'testMethodDefinition';
		assert: method category equals: self class name;
		assert: method source
			equals:
			'testMethodDefinition
	^x + 1' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'MethodRemove';
				at: 'class' put: 'Point';
				at: 'selector' put: 'testMethodDefinition';
				yourself.
			self post: '/changes' with: remotion ]