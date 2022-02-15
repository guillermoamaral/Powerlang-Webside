changes endpoints
testClassRename
	| definition renaming class |
	definition := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestClassRename';
		definition:
			'Object
	subclass: #TestClassRename
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	renaming := NeoJSONObject new
		at: 'type' put: 'ClassRename';
		at: 'class' put: 'TestClassRename';
		at: 'newName' put: 'TestClassRename2';
		yourself.
	[ self
		post: '/changes' with: definition;
		post: '/changes' with: renaming.
	class := self get: '/classes/TestClassRename'.
	self assert: class isNil.
	class := self get: '/classes/TestClassRename2'.
	self assert: class notNil ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestClassRename2';
				yourself.
			self post: '/changes' with: remotion ]