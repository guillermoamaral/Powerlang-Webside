changes endpoints
testCategoryRemove
	| class method remotion |
	class := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestCategoryRemove';
		at: 'definition'
			put:
			'Object
	subclass: #TestCategoryRemove
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	method := NeoJSONObject new
		at: 'type' put: 'MethodDefinition';
		at: 'class' put: 'TestCategoryRemove';
		at: 'category' put: 'x';
		at: 'sourceCode' put: 'testCategoryRemove';
		at: 'author' put: self class name;
		yourself.
	remotion := NeoJSONObject new
		at: 'type' put: 'CategoryRemove';
		at: 'class' put: 'TestCategoryRemove';
		at: 'category' put: 'x';
		yourself.
	[ | categories |
	self
		post: '/changes' with: class;
		post: '/changes' with: method;
		post: '/changes' with: remotion.
	categories := self get: '/classes/TestCategoryRemove/categories'.
	self deny: (categories includes: 'x') ]
		ensure: [ remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestCategoryRemove';
				yourself.
			self post: '/changes' with: remotion ]