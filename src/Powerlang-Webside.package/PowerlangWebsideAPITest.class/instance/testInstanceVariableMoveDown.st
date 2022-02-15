changes endpoints
testInstanceVariableMoveDown
	| superclass class movement |
	superclass := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestInstanceVariableMoveDown';
		at: 'definition'
			put:
			'Object
	subclass: #TestInstanceVariableMoveDown
	instanceVariableNames: ''x''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	class := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestInstanceVariableMoveDown2';
		at: 'definition'
			put:
			'TestInstanceVariableMoveDown
	subclass: #TestInstanceVariableMoveDown2
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	movement := NeoJSONObject new
		at: 'type' put: 'InstanceVariableMoveDown';
		at: 'class' put: 'TestInstanceVariableMoveDown';
		at: 'variable' put: 'x';
		at: 'target' put: 'TestInstanceVariableMoveDown2';
		yourself.
	[ | variables |
	self
		post: '/changes' with: superclass;
		post: '/changes' with: class;
		post: '/changes' with: movement.
	variables := self
		get: '/classes/TestInstanceVariableMoveDown/instance-variables'.
	self assert: variables isEmpty.
	variables := self
		get: '/classes/TestInstanceVariableMoveDown2/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'x' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestInstanceVariableMoveDown2';
				yourself.
			self post: '/changes' with: remotion.
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestInstanceVariableMoveDown';
				yourself.
			self post: '/changes' with: remotion ]