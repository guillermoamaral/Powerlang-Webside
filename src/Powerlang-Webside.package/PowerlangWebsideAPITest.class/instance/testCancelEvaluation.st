evaluation  endpoints
testCancelEvaluation
	| evaluation result id active |
	evaluation := NeoJSONObject new
		at: 'expression' put: 'Delay wait: 10000';
		at: 'sync' put: false;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	id := result at: 'id'.
	self delete: '/evaluations/' , id asString.
	active := self get: '/evaluations'.
	self assert: (active noneSatisfy: [ :e | (e at: 'id') = id ])