workspaces endpoints
testWorkspace
	| id |
	id := self post: '/workspaces'.
	[ | context assignment evaluation result |
	context := NeoJSONObject new
		at: 'workspace' put: id;
		yourself.
	assignment := NeoJSONObject new
		at: 'expression' put: 'a := 1';
		at: 'sync' put: true;
		context: context;
		yourself.
	self post: '/evaluations' with: assignment.
	evaluation := NeoJSONObject new
		at: 'expression' put: 'a';
		at: 'sync' put: true;
		context: context;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	self
		assert: (result at: 'class') equals: 'SmallInteger';
		assert: (result at: 'printString') equals: '1' ]
		ensure: [ self delete: '/workspaces/' , id ]