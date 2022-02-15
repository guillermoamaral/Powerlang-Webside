objects endpoints
testPinnedObject
	| evaluation result id |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	[ | pinned |
	id := result at: 'id'.
	pinned := self get: '/objects/' , id asString.
	self
		assert: (pinned at: 'id') equals: id;
		assert: (pinned at: 'class') equals: 'SmallInteger';
		assert: (pinned at: 'printString') equals: '7' ]
		ensure: [ self delete: '/objects/' , id asString ]