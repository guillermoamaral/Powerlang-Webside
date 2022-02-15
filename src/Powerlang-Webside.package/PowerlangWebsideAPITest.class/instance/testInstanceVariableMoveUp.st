changes endpoints
testInstanceVariableMoveUp
	| superclass class movement |
	superclass := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestInstanceVariableMoveUp';
		definition:
			'Object
	subclass: #TestInstanceVariableMoveUp
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	class := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestInstanceVariableMoveUp2';
		at: 'definition'
			put:
			'TestInstanceVariableMoveUp
	subclass: #TestInstanceVariableMoveUp2
	instanceVariableNames: ''x''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	movement := NeoJSONObject new
		at: 'type' put: 'InstanceVariableMoveUp';
		at: 'class' put: 'TestInstanceVariableMoveUp2';
		at: 'variable' put: 'x';
		yourself.
	[ | variables |
	self
		post: '/changes' with: superclass;
		post: '/changes' with: class;
		post: '/changes' with: movement.
	variables := self
		get: '/classes/TestInstanceVariableMoveUp/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'x'.
	variables := self
		get: '/classes/TestInstanceVariableMoveUp2/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'x';
		assert: (variables first at: 'class')
			equals: 'TestInstanceVariableMoveUp' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestInstanceVariableMoveUp2';
				yourself.
			self post: '/changes' with: remotion.
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestInstanceVariableMoveUp';
				yourself.
			self post: '/changes' with: remotion ]