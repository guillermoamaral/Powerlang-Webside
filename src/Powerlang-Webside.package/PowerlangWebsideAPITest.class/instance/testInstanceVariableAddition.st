changes endpoints
testInstanceVariableAddition
	| definition addition |
	definition := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestInstanceVariableAddition';
		definition:
			'Object
	subclass: #TestInstanceVariableAddition
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	addition := NeoJSONObject new
		at: 'type' put: 'InstanceVariableAddition';
		at: 'class' put: 'TestInstanceVariableAddition';
		at: 'variable' put: 'x';
		yourself.
	[ | variables |
	self
		post: '/changes' with: definition;
		post: '/changes' with: addition.
	variables := self
		get: '/classes/TestInstanceVariableAddition/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'x' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestInstanceVariableAddition';
				yourself.
			self post: '/changes' with: remotion ]