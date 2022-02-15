changes endpoints
testCassDefinition
	| definition |
	definition := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestCassDefinition';
		at: 'definition'
			put:
			'Object
	subclass: #TestCassDefinition
	instanceVariableNames: ''x''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	[ | class |
	self post: '/changes' with: definition.
	class := self get: '/classes/TestCassDefinition'.
	self
		assert: class notNil;
		assert: class name equals: 'TestCassDefinition' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestCassDefinition';
				yourself.
			self post: '/changes' with: remotion ]