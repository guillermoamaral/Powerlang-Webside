evaluation  endpoints
testSynchronousEvaluation
	| evaluation result |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	self
		assert: (result at: 'class') equals: 'SmallInteger';
		assert: (result at: 'printString') equals: '7'