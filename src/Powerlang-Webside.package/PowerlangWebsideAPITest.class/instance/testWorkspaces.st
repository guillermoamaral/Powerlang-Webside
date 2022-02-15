workspaces endpoints
testWorkspaces
	| id result |
	id := self post: '/workspaces'.
	[result := self get: '/workspaces'.
	self
		assert: (result anySatisfy: [:w | (w at: 'id') = id])]
		ensure: [ self delete: '/workspaces/' , id ]