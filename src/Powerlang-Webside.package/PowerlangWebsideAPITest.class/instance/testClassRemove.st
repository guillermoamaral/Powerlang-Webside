changes endpoints
testClassRemove
	| definition remotion class |
	definition := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestClassRemove';
		definition:
			'Object
	subclass: #TestClassRemove
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	remotion := NeoJSONObject new
		at: 'type' put: 'ClassRemove';
		at: 'class' put: 'TestClassRemove';
		yourself.
	self
		post: '/changes' with: definition;
		post: '/changes' with: remotion.
	class := self get: '/classes/TestClassRemove'.
	self assert: class isNil