objects endpoints
testPinnedObjectSlot
	| evaluation result id x |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 @ 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	id := result at: 'id'.
	self assert: (result at: 'class') equals: 'Point'.
	x := self get: '/objects/' , id asString , '/x'.
	self
		assert: (x at: 'class') equals: 'SmallInteger';
		assert: (x at: 'printString') equals: '3'