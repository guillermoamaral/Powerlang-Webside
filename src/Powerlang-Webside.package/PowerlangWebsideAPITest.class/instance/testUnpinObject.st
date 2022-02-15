objects endpoints
testUnpinObject
	| evaluation result id pinned |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	id := result at: 'id'.
	self delete: '/objects/' , id asString.
	pinned := self get: '/objects'.
	self assert: (pinned noneSatisfy: [ :o | (o at: 'id') = id ])