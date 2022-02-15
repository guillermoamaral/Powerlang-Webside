changes endpoints
testInstanceVariableRemove
	| definition remotion |
	definition := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestInstanceVariableRemove';
		at: 'definition'
			put:
			'Object
	subclass: #TestInstanceVariableRemove
	instanceVariableNames: ''x''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	remotion := NeoJSONObject new
		at: 'type' put: 'InstanceVariableRemove';
		at: 'class' put: 'TestInstanceVariableRemove';
		at: 'variable' put: 'x';
		yourself.
	[ | variables |
	self
		post: '/changes' with: definition;
		post: '/changes' with: remotion.
	variables := self
		get: '/classes/TestInstanceVariableRemove/instance-variables'.
	self assert: variables isEmpty ]
		ensure: [ remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestInstanceVariableRemove';
				yourself.
			self post: '/changes' with: remotion ]