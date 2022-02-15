changes endpoints
testSelectorRename2
	| definition renaming |
	definition := NeoJSONObject new
		at: 'type' put: 'MethodDefinition';
		at: 'class' put: 'Point';
		at: 'category' put: self class name;
		at: 'sourceCode'
			put:
			'testSelectorRename
	^x + 1';
		at: 'author' put: self class name;
		yourself.
	renaming := NeoJSONObject new
		at: 'type' put: 'SelectorRename';
		at: 'class' put: 'Point';
		at: 'selector' put: #testSelectorRename2;
		at: 'newSelector' put: 'testSelectorRename2';
		at: 'author' put: self class name;
		yourself.
	[ | method |
	self
		post: '/changes' with: definition;
		post: '/changes' with: renaming.
	method := self get: '/classes/Point/methods/testSelectorRename'.
	self assert: method isNil.
	method := self get: '/classes/Point/methods/testSelectorRename2'.
	self assert: method notNil ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'MethodRemove';
				at: 'class' put: 'Point';
				at: 'selector' put: 'testSelectorRename2';
				yourself.
			self post: '/changes' with: remotion ]