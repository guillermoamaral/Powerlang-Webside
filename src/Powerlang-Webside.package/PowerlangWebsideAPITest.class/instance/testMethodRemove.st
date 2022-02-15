changes endpoints
testMethodRemove
	| definition remotion method |
	definition := NeoJSONObject new
		at: 'type' put: 'MethodDefinition';
		at: 'class' put: 'Point';
		at: 'category' put: self class name;
		at: 'sourceCode'
			put:
			'testMethodRemove
	^x + 1';
		at: 'author' put: self class name;
		yourself.
	remotion := NeoJSONObject new
		at: 'type' put: 'MethodRemove';
		at: 'class' put: 'Point';
		at: 'selector' put: 'testMethodRemove';
		yourself.
	self
		post: '/changes' with: definition;
		post: '/changes' with: remotion.
	method := self get: '/classes/Point/methods/testMethodRemove'.
	self assert: method isNil