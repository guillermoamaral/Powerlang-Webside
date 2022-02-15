evaluation  endpoints
testPinEvaluationResult
	| evaluation result |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	[ self
		assert: (result includesKey: 'id');
		assert: (result at: 'class') equals: 'SmallInteger';
		assert: (result at: 'printString') equals: '7' ]
		ensure: [ self delete: '/objects/' , (result at: 'id') asString ]