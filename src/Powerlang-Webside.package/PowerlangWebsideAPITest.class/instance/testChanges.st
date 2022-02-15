changes endpoints
testChanges
	| change changes |
	change := NeoJSONObject new
		at: 'type' put: 'MethodDefinition';
		at: 'class' put: 'Point';
		at: 'category' put: self class name;
		at: 'sourceCode'
			put:
			'testChanges
	^x + 1';
		at: 'author' put: self class name;
		yourself.
	[ | retrieved |
	self post: '/changes' with: change.
	changes := self get: '/changes'.
	self assert: changes notEmpty.
	retrieved := changes last.
	self
		assert: (retrieved at: 'type') equals: 'MethodDefinition';
		assert: (retrieved at: 'class') equals: 'Point';
		assert: (retrieved at: 'selector') equals: 'testChanges' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'MethodRemove';
				at: 'class' put: 'Point';
				at: 'selector' put: 'testMethodDefinition';
				yourself.
			self post: '/changes' with: remotion ]