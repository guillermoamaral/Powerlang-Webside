debugging endpoints
testFrameBindings
	| evaluation id debugger |
	evaluation := NeoJSONObject new
		at: 'expression' put: '1 halt factorial';
		at: 'sync' put: true;
		yourself.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | id := e data at: 'evaluation' ].
	self assert: id notNil.
	[ | target frames bindings |
	target := NeoJSONObject new
		at: 'evaluation' put: id;
		yourself.
	debugger := self post: '/debuggers' with: target.
	frames := self get: '/debuggers/' , debugger , '/frames'.
	self assert: frames notEmpty.
	bindings := self get: '/debuggers/' , debugger , '/frames/1/bindings'.
	self
		assert: bindings notEmpty;
		assert: (bindings anySatisfy: [ :b | (b at: 'name') = 'self' ]) ]
		ensure: [ self delete: '/debuggers/' , debugger asString ]