objects endpoints
testPinnedObjectInstanceVariables
	| evaluation result id vars |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 @ 4 extent: 1 @ 1';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	id := result at: 'id'.
	self assert: (result at: 'class') equals: 'Rectangle'.
	vars := self get: '/objects/' , id asString , '/instance-variables'.
	self
		assert: vars size equals: Rectangle allInstVarNames size;
		assert:
			(Rectangle allInstVarNames
				allSatisfy: [ :n | vars anySatisfy: [ :v | (v at: 'name') = n ] ]).
	vars := self
		get: '/objects/' , id asString , '/corner/instance-variables'.
	self
		assert: vars size equals: Point allInstVarNames size;
		assert:
			(Point allInstVarNames
				allSatisfy: [ :n | vars anySatisfy: [ :v | (v at: 'name') = n ] ])