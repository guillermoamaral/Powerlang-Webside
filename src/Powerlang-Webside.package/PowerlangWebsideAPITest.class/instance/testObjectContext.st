evaluation  endpoints
testObjectContext
	| evaluation object |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 @ 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	object := self post: '/evaluations' with: evaluation.
	[ | context x |
	context := NeoJSONObject new
		at: 'object' put: (object at: 'id');
		yourself.
	evaluation := NeoJSONObject new
		at: 'expression' put: 'x';
		at: 'sync' put: true;
		at: 'pin' put: false;
		at: 'context' put: context;
		yourself.
	x := self post: '/evaluations' with: evaluation.
	self
		assert: (x at: 'class') equals: 'SmallInteger';
		assert: (x at: 'printString') equals: '3' ]
		ensure: [ self delete: '/objects/' , (object at: 'id') asString ]