evaluation  endpoints
testActiveEvaluations
	| evaluation result id |
	evaluation := NeoJSONObject new
		at: 'expression' put: '(Delay forSeconds: 1) wait';
		at: 'sync' put: false;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	[ | active |
	id := result at: 'id'.
	active := self get: '/evaluations'.
	self
		assert: active notEmpty;
		assert: (active anySatisfy: [ :e | (e at: 'id') = id ]) ]
		ensure: [ self delete: '/evaluations/' , id asString ]