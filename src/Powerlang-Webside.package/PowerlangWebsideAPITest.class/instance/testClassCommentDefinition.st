changes endpoints
testClassCommentDefinition
	| definition comment |
	definition := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestClassCommentDefinition';
		at: 'definition'
			put:
			'Object
	subclass: #TestClassCommentDefinition
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	comment := NeoJSONObject new
		at: 'type' put: 'ClassCommentDefinition';
		at: 'class' put: 'TestClassCommentDefinition';
		at: 'comment' put: 'Testing class comment';
		yourself.
	[ | class |
	self
		post: '/changes' with: definition;
		post: '/changes' with: comment.
	class := self get: '/classes/TestClassCommentDefinition'.
	self
		assert: class notNil;
		assert: class comment equals: 'Testing class comment' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestClassCommentDefinition';
				yourself.
			self post: '/changes' with: remotion ]