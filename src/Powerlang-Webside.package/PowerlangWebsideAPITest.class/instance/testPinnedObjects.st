objects endpoints
testPinnedObjects
	| evaluation result id |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	[ | pinned |
	id := result at: 'id'.
	pinned := self get: '/objects'.
	self
		assert:
			(pinned
				anySatisfy: [ :o | 
					(o at: 'id') = id
						and: [ (o at: 'class') = 'SmallInteger' 
						and: [ (o at: 'printString') = '7' ]] ]) ]
		ensure: [ self delete: '/objects/' , id asString ]