changes endpoints
testCodeSuggestion
	| change method error data changes |
	change := NeoJSONObject new
		at: 'type' put: 'MethodDefinition';
		at: 'class' put: 'Point';
		at: 'category' put: self class name;
		at: 'sourceCode'
			put:
			'testMethodDefinition
	^t + 1';
		at: 'author' put: self class name;
		yourself.
	[ [ self post: '/changes' with: change ]
		on: Error
		do: [ :e | error := e ].
	self
		assert: error notNil;
		assert: error class = Error.
	data := error data.
	self assert: data notNil.
	changes := data at: 'changes'.
	self post: '/changes' with: changes first.
	method := self get: '/classes/Point/methods/testMethodDefinition'.
	self
		assert: method notNil;
		assert: method selector equals: 'testMethodDefinition';
		assert: method category equals: self class name;
		assert: method source
			equals:
			'testMethodDefinition
	| t |
	^t + 1' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'MethodRemove';
				at: 'class' put: 'Point';
				at: 'selector' put: 'testMethodDefinition';
				yourself.
			self post: '/changes' with: remotion ]