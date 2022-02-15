changes endpoints
testInstanceVariableRename
	| definition renaming |
	definition := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestInstanceVariableRename';
		at: 'definition'
			put:
			'Object
	subclass: #TestInstanceVariableRename
	instanceVariableNames: ''x''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	renaming := NeoJSONObject new
		at: 'type' put: 'InstanceVariableRename';
		at: 'class' put: 'TestInstanceVariableRename';
		at: 'variable' put: 'x';
		at: 'newName' put: 'y';
		yourself.
	[ | variables |
	self
		post: '/changes' with: definition;
		post: '/changes' with: renaming.
	variables := self
		get: '/classes/TestInstanceVariableRename/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'y' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestInstanceVariableRename';
				yourself.
			self post: '/changes' with: remotion ]