Class {
	#name : #PowerlangWebsideAPI,
	#superclass : #Object,
	#instVars : [
		'request',
		'server',
		'runtime'
	],
	#classVars : [
		'Debuggers',
		'Evaluations',
		'Objects',
		'Workspaces'
	],
	#category : #'Powerlang-Webside'
}

{ #category : #'instance creation' }
PowerlangWebsideAPI class >> new [
	^ super new initialize
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> categories [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ class protocols
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> classDefinition [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ class asWebsideJson
]

{ #category : #private }
PowerlangWebsideAPI >> classNamed: aString [
	| name metaclass class |
	name := aString.
	metaclass := name endsWith: ' class'.
	metaclass
		ifTrue: [ name := name withoutSuffix: ' class' ].
	class := runtime image => name.
	^ metaclass
		ifTrue: [ class metaclass ]
		ifFalse: [ class ]
]

{ #category : #private }
PowerlangWebsideAPI >> classTreeFrom: aClass depth: anInteger [
	| json subclasses depth names |
	names := self queryAt: 'names'.
	json := names = 'true'
		ifTrue: [ NeoJSONObject new
				at: 'name' put: aClass name;
				at: 'superclass'
					put: (aClass superclass ifNotNil: [ :c | c name ]);
				yourself ]
		ifFalse: [ aClass asWebsideJson ].
	(anInteger notNil and: [ anInteger = 0 ])
		ifTrue: [ ^ json ].
	depth := anInteger notNil
		ifTrue: [ anInteger - 1 ].
	subclasses := (aClass subclasses sort: [ :a :b | a name <= b name ])
		collect: [ :c | self classTreeFrom: c depth: depth ].
	json at: 'subclasses' put: subclasses.
	^ json
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> classVariables [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ class withAllSuperclasses
		gather: [ :c | 
			c classVarNames asArray sort
				collect: [ :v | 
					NeoJSONObject new
						at: 'name' put: v;
						at: 'class' put: c name , ' class';
						yourself ] ]
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> classes [
	| root tree classes names depth json |
	root := self queryAt: 'root'.
	root := root notNil
		ifTrue: [ self classNamed: root ]
		ifFalse: [ self defaultRootClass ].
	root ifNil: [ ^ self notFound ].
	tree := self queryAt: 'tree'.
	tree = 'true'
		ifTrue: [ depth := self queryAt: 'depth'.
			depth notNil
				ifTrue: [ depth := depth asInteger ].
			json := self classTreeFrom: root depth: depth.
			^ Array with: json ].
	classes := root withAllSubclasses.
	names := self queryAt: 'names'.
	names = 'true'
		ifTrue: [ ^ (classes collect: #name) sort ].
	^ classes collect: #asWebsideJson
]

{ #category : #private }
PowerlangWebsideAPI >> defaultRootClass [
	^ runtime image => 'Object'
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> dialect [
	^ 'Powerlang-Ring'
]

{ #category : #private }
PowerlangWebsideAPI >> filterByCategory: aCollection [
	| category |
	category := self queriedCategory.
	^ (category notNil and: [ category notEmpty ])
		ifTrue: [ aCollection select: [ :m | m category = category ] ]
		ifFalse: [ aCollection ]
]

{ #category : #private }
PowerlangWebsideAPI >> filterByVariable: aCollection [
	| variable class slot classVar |
	variable := self queriedReferencing.
	variable ifNil: [ ^ aCollection ].
	^ aCollection
		select: [ :m | 
			class := m methodClass.
			(class hasSlotNamed: variable)
				ifTrue: [ slot := class slotNamed: variable ].
			(class classVarNames includes: variable)
				ifTrue: [ classVar := class classVarNamed: variable ].
			(slot notNil
				and: [ (slot isReadIn: m) or: [ slot isWrittenIn: m ] ])
				or: [ classVar notNil and: [ classVar isReferencedIn: m ] ] ]
]

{ #category : #private }
PowerlangWebsideAPI >> implementorsOf: aSymbol [
	| scope |
	scope := self queriedScope.
	^ scope
		ifNotNil: [ scope implementorsOf: aSymbol ]
		ifNil: [ SystemNavigation default allImplementorsOf: aSymbol ]
]

{ #category : #initialization }
PowerlangWebsideAPI >> initialize [
	super initialize.
	self initializeRuntime
]

{ #category : #initialization }
PowerlangWebsideAPI >> initializeRuntime [
	| image |
	image := VirtualSmalltalkImage fromSpec
		wordSize: 8;
		genesis.
	runtime := VirtualSmalltalkRuntime new
		image: image;
		initializeClassPools
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> instanceVariables [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ class withAllSuperclasses
		gather: [ :c | 
			c instVarNames
				collect: [ :v | 
					NeoJSONObject new
						at: 'name' put: v;
						at: 'class' put: c name;
						yourself ] ]
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> method [
	| class selector |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	selector := self requestedSelector.
	selector ifNil: [ ^ self notFound ].
	(class includesSelector: selector)
		ifFalse: [ ^ self notFound ].
	^ (class >> selector) asWebsideJson
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> methods [
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
		ifNil: [ methods := (class ifNil: [ self defaultRootClass ]) methodDict
				asArray ].
	methods := self filterByCategory: methods.
	methods := self filterByVariable: methods.
	^ methods collect: #asWebsideJson
]

{ #category : #private }
PowerlangWebsideAPI >> notFound [
	^ ZnResponse notFound: 'resource not found'
]

{ #category : #private }
PowerlangWebsideAPI >> queriedCategory [
	| category |
	category := request at: 'category' ifAbsent: nil.
	^ category ifNotNil: [ category asSymbol ]
]

{ #category : #private }
PowerlangWebsideAPI >> queriedClass [
	| name |
	name := request at: 'class' ifAbsent: nil.
	^ name ifNotNil: [ self classNamed: name ]
]

{ #category : #private }
PowerlangWebsideAPI >> queriedReferencing [
	^ self queriedReferencingClass ifNil: [ self queryAt: 'referencing' ]
]

{ #category : #private }
PowerlangWebsideAPI >> queriedReferencingClass [
	| name |
	name := self queryAt: 'referencing'.
	^ name ifNotNil: [ self classNamed: name ]
]

{ #category : #private }
PowerlangWebsideAPI >> queriedScope [
	| scope |
	scope := request at: 'scope' ifAbsent: nil.
	^ scope ifNotNil: [ self classNamed: scope ]
]

{ #category : #private }
PowerlangWebsideAPI >> queriedSelector [
	| selector |
	selector := request at: 'selector' ifAbsent: nil.
	^ selector ifNotNil: [ selector asSymbol ]
]

{ #category : #private }
PowerlangWebsideAPI >> queriedSending [
	| selector |
	selector := request at: 'sending' ifAbsent: nil.
	^ selector ifNotNil: [ selector asSymbol ]
]

{ #category : #private }
PowerlangWebsideAPI >> queryAt: aString [
	^request at: aString ifAbsent: nil
]

{ #category : #private }
PowerlangWebsideAPI >> referencesTo: aClass [
	| binding |
	binding := Smalltalk bindingOf: aClass name asSymbol.
	^ SystemNavigation default allReferencesTo: binding
]

{ #category : #accessing }
PowerlangWebsideAPI >> request: aTeaRequest [
	request := aTeaRequest
]

{ #category : #private }
PowerlangWebsideAPI >> requestedClass [
	| name |
	name := self urlAt: 'name'.
	^ name ifNotNil: [ self classNamed: name ]
]

{ #category : #private }
PowerlangWebsideAPI >> requestedSelector [
	| selector |
	selector := self urlAt: 'selector'.
	^ selector ifNotNil: [ selector asSymbol ]
]

{ #category : #private }
PowerlangWebsideAPI >> sendersOf: aSymbol [
	| scope |
	scope := self queriedScope.
	^ scope
		ifNotNil: [ scope sendersOf: aSymbol ]
		ifNil: [ SystemNavigation default allSendersOf: aSymbol ]
]

{ #category : #accessing }
PowerlangWebsideAPI >> server: aWebsideServer [
	server := aWebsideServer
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> subclasses [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ class subclasses collect: #asWebsideJson
]

{ #category : #private }
PowerlangWebsideAPI >> urlAt: aString [
	^ request at: aString ifAbsent: nil
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> variables [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ self instanceVariables , self classVariables
]
