debugging endpoints
testStepInto
	| evaluation id debugger |
	evaluation := NeoJSONObject new
		at: 'expression' put: '1 halt factorial';
		at: 'sync' put: true;
		yourself.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | id := e data at: 'evaluation' ].
	self assert: id notNil.
	[ | target frame |
	target := NeoJSONObject new
		at: 'evaluation' put: id;
		yourself.
	debugger := self post: '/debuggers' with: target.
	self post: '/debuggers/' , debugger , '/frames/1/stepinto'.
	frame := self get: '/debuggers/' , debugger , '/frames/1'.
	self assert: ((frame at: 'method') at: 'selector') equals: 'factorial' ]
		ensure: [ self delete: '/debuggers/' , debugger asString ]