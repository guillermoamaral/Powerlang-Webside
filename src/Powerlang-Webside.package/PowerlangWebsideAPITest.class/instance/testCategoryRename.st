changes endpoints
testCategoryRename
	| class method renaming |
	class := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestCategoryRename';
		at: 'definition'
			put:
			'Object
	subclass: #TestCategoryRename
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	method := NeoJSONObject new
		at: 'type' put: 'MethodDefinition';
		at: 'class' put: 'TestCategoryRename';
		at: 'category' put: 'x';
		at: 'sourceCode' put: 'testCategoryRename';
		at: 'author' put: self class name;
		yourself.
	renaming := NeoJSONObject new
		at: 'type' put: 'CategoryRename';
		at: 'class' put: 'TestCategoryRename';
		at: 'category' put: 'x';
		at: 'newName' put: 'y';
		yourself.
	[ | categories |
	self
		post: '/changes' with: class;
		post: '/changes' with: method;
		post: '/changes' with: renaming.
	categories := self get: '/classes/TestCategoryRename/categories'.
	self
		assert: categories size equals: 1;
		assert: categories first name equals: 'y' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestCategoryRename';
				yourself.
			self post: '/changes' with: remotion ]