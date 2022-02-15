code endpoints
methods
	| selector methods senders global references class |
	selector := self queriedSelector.
	selector notNil
		ifTrue: [ methods := self implementorsOf: selector ]. 
	selector := self queriedSending.
	selector notNil
		ifTrue: [ senders := self sendersOf: selector.
			methods := methods
				ifNil: [ senders ]
				ifNotNil: [ methods intersection: senders ] ].
	global := self queriedReferencingClass.
	global notNil
		ifTrue: [ references := self referencesTo: global.
			methods := methods
				ifNil: [ references ]
				ifNotNil: [ methods intersection: references ] ].
	class := self requestedClass ifNil: [ self queriedClass ].
	(class notNil and: [ methods notNil ])
		ifTrue: [ methods := methods select: [ :m | m methodClass == class ] ].
	methods
		ifNil: [ methods := (class ifNil: [ self defaultRootClass ]) methodDictionary
				asArray ].
	methods := self filterByCategory: methods.
	methods := self filterByVariable: methods.
	^ methods collect: #asWebsideJson