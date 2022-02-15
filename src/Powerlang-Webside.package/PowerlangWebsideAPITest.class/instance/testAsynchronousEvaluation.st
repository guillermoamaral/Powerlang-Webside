evaluation  endpoints
testAsynchronousEvaluation
	| evaluation result id |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: false;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	[ | attempts object |
	id := result at: 'id'.
	self
		assert: (result includesKey: 'id');
		deny: (result at: 'printString' ifAbsent: '') equals: '7'.
	attempts := 0.
	object := nil.
	[ attempts <= 3 and: [ object isNil ] ]
		whileTrue: [ attempts := attempts + 1.
			(Delay forMilliseconds: 200) wait.
			object := self get: '/objects/' , id asString ].
	self
		assert: object notNil;
		assert: (object at: 'id') equals: id;
		assert: (object at: 'class') equals: 'SmallInteger';
		assert: (object at: 'printString') equals: '7' ]
		ensure: [ self delete: '/objects/' , id asString ]