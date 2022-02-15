debugging endpoints
testCreateDebugger
	| evaluation halt id debugger |
	evaluation := NeoJSONObject new
		at: 'expression' put: '1 halt factorial';
		at: 'sync' put: true;
		yourself.
	halt := false.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | 
			| error |
			halt := true.
			self
				assert: (e isKindOf: Error);
				assert: e hasData.
			error := e data.
			self
				assert: ((error at: 'description') asLowercase includesSubstring: 'halt');
				assert: (error includesKey: 'evaluation').
			id := error at: 'evaluation' ].
	self
		assert: halt;
		assert: id notNil.
	[ | target frames |
	target := NeoJSONObject new
		at: 'evaluation' put: id;
		yourself.
	debugger := self post: '/debuggers' with: target.
	self assert: debugger notNil.
	frames := self get: '/debuggers/' , debugger , '/frames'.
	self assert: frames notEmpty ]
		ensure: [ debugger notNil
				ifTrue: [ self delete: '/debuggers/' , debugger asString ] ]