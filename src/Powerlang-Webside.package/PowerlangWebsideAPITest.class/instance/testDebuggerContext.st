evaluation  endpoints
testDebuggerContext
	| evaluation id debugger error |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 halt factorial';
		at: 'sync' put: true;
		yourself.
	self post: '/evaluations' with: evaluation.
	self deny: client isSuccess .
	error := NeoJSONObject fromString: client response entity string.
	id := error at: 'evaluation'.
	self assert: id notNil.
	[ | target context receiver |
	target := NeoJSONObject new
		at: 'evaluation' put: id;
		yourself.
	debugger := self post: '/debuggers' with: target.
	self post: '/debuggers/' , debugger , '/frames/1/stepinto'.
	context := NeoJSONObject new
		at: 'debugger' put: debugger asString;
		at: 'frame' put: 1;
		yourself.
	evaluation := NeoJSONObject new
		at: 'expression' put: 'self';
		at: 'sync' put: true;
		at: 'pin' put: false;
		at: 'context' put: context;
		yourself.
	receiver := self post: '/evaluations' with: evaluation.
	self
		assert: (receiver at: 'class') equals: 'SmallInteger';
		assert: (receiver at: 'printString') equals: '3' ]
		ensure: [ self delete: '/debuggers/' , debugger asString ]