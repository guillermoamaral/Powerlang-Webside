code endpoints
testClasses
	| classes names tree root integer |
	classes := self get: 'classes?root=Magnitude'.
	self
		assert:
			(classes
				anySatisfy: [ :c | 
					c name = 'Fraction'
						and: [ c definition includesSubstring: 'denominator' ] ]).
	names := self get: 'classes?root=Magnitude&names=true'.
	self
		assert: names notEmpty;
		assert: (names allSatisfy: #isString).
	tree := self get: 'classes?root=Number&tree=true'.
	self
		assert: tree isCollection;
		assert: tree size equals: 1.
	root := tree first.
	self
		assert: root name = 'Number';
		assert: (root subclasses anySatisfy: [ :c | c name = 'Integer' ]).
	integer := root subclasses detect: [ :c | c name = 'Integer' ].
	self
		assert: (integer subclasses anySatisfy: [ :c | c name = 'SmallInteger' ])