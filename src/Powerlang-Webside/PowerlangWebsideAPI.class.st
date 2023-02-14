"
self startServer


self allInstances
"
Class {
	#name : #PowerlangWebsideAPI,
	#superclass : #Object,
	#instVars : [
		'request',
		'server'
	],
	#classVars : [
		'Debuggers',
		'Evaluations',
		'Objects',
		'Workspaces'
	],
	#category : #'Powerlang-Webside-Base'
}

{ #category : #'instance creation' }
PowerlangWebsideAPI class >> new [
	^ super new initialize
]

{ #category : #services }
PowerlangWebsideAPI class >> startServer [
	"
	self startServer
	"

	| bootstrapper |
	bootstrapper := PowertalkRingImage fromSpec
		wordSize: 8;
		genesis;
		bootstrap;
		fillClasses;
		fillSymbols;
		generateLMR.
	^ WebsideServer new
		apiClass: PowerlangWebsideAPI;
		baseUri: '/powerlang';
		port: 9002;
		resourcesAt: #runtime put: bootstrapper result;
		start
]

{ #category : #services }
PowerlangWebsideAPI class >> stopServer [
	"
	self stopServer
	"

	WebsideServer allInstances do: #stop
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> categories [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ class categories
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

	| name metaclass runtime root class |
	name := aString.
	metaclass := name endsWith: ' class'.
	metaclass ifTrue: [ name := name withoutSuffix: ' class' ].
	runtime := self runtime.
	root := (PowerlangObjectWrapper on: runtime nil runtime: runtime)
		        objectClass.

	[ root superclass wrappee == runtime nil ] whileFalse: [ 
		root := root superclass ].
	class := root withAllSubclasses
		         detect: [ :c | c name = name ]
		         ifNone: [ ^ nil ].
	^ metaclass
		  ifTrue: [ class class ]
		  ifFalse: [ class ]
]

{ #category : #private }
PowerlangWebsideAPI >> classTreeFrom: aPowerlangSpeciesWrapper depth: anInteger [
	| json subclasses depth names superclass |
	names := self queryAt: 'names'.
	json := names = 'true'
		ifTrue: [ superclass := aPowerlangSpeciesWrapper superclass.
			NeoJSONObject new
				at: 'name' put: aPowerlangSpeciesWrapper name;
				at: 'superclass'
					put:
					(superclass == self runtime nil
						ifFalse: [ superclass name ]);
				yourself ]
		ifFalse: [ aPowerlangSpeciesWrapper asWebsideJson ].
	(anInteger notNil and: [ anInteger = 0 ])
		ifTrue: [ ^ json ].
	depth := anInteger notNil
		ifTrue: [ anInteger - 1 ].
	subclasses := (aPowerlangSpeciesWrapper subclasses
		sort: [ :a :b | a name <= b name ])
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
						at: 'type' put: 'class';
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
	tree = 'true' ifTrue: [ 
		depth := self queryAt: 'depth' ifPresent: [ :d | d asInteger ].
		json := self classTreeFrom: root depth: depth.
		^ Array with: json ].
	classes := Array with: root withAll: root allSubclasses.
	names := self queryAt: 'names'.
	names = 'true' ifTrue: [ ^ (classes collect: [ :c | c name ]) sort ].
	^ classes collect: [ :c | c asWebsideJson ]
]

{ #category : #private }
PowerlangWebsideAPI >> defaultRootClass [
	^ self classNamed: 'ProtoObject'
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> dialect [

	^ 'Powerlang'
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
	variable := self queriedAccessing.
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
PowerlangWebsideAPI >> image [
	^ self runtime image
]

{ #category : #private }
PowerlangWebsideAPI >> implementorsOf: aSymbol [
	| scope |
	scope := self queriedScope.
	^ scope
		ifNotNil: [ scope implementorsOf: aSymbol ]
		ifNil: [ SystemNavigation default allImplementorsOf: aSymbol ]
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
						at: 'type' put: 'instance';
						yourself ] ]
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> method [

	| class selector symbol |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	selector := self requestedSelector.
	selector ifNil: [ ^ self notFound ].
	symbol := self runtime symbolFromLocal: selector.
	(class includesSelector: symbol) asLocalObject ifFalse: [ 
		^ self notFound ].
	^ (class >> symbol) asWebsideJson
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
		ifNil: [ methods := (class ifNil: [ self defaultRootClass ]) methods ].
	methods := self filterByCategory: methods.
	methods := self filterByVariable: methods.
	^ methods collect: [ :m | m asWebsideJson ]
]

{ #category : #private }
PowerlangWebsideAPI >> notFound [
	^ ZnResponse notFound: 'resource not found'
]

{ #category : #private }
PowerlangWebsideAPI >> queriedAccessing [
	^ self queryAt: 'accessing' 
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
PowerlangWebsideAPI >> queriedReferencingClass [
	^self queryAt: 'referencingClass' ifPresent: [:n | self classNamed: n ]
]

{ #category : #private }
PowerlangWebsideAPI >> queriedReferencingString [
	^self queryAt: 'referencingString'
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
	^ self queryAt: aString ifAbsent: nil
]

{ #category : #private }
PowerlangWebsideAPI >> queryAt: aString ifAbsent: aBlock [
	^ self queryAt: aString ifPresent: nil ifAbsent: aBlock
]

{ #category : #private }
PowerlangWebsideAPI >> queryAt: aString ifPresent: aBlock [
	^ self queryAt: aString ifPresent: aBlock ifAbsent: nil
]

{ #category : #private }
PowerlangWebsideAPI >> queryAt: aString ifPresent: aBlock ifAbsent: anotherBlock [

	| value |
	value := request at: aString ifAbsent: nil.
	value ifNil: [ ^ anotherBlock value ].
	^ aBlock notNil
		  ifTrue: [ aBlock value: value ]
		  ifFalse: [ value ]
]

{ #category : #private }
PowerlangWebsideAPI >> referencesToClass: aClass [
	| binding |
	binding := Smalltalk bindingOf: aClass name asSymbol.
	^ SystemNavigation default allReferencesTo: binding
]

{ #category : #private }
PowerlangWebsideAPI >> referencesToString: aString [
	| scope |
	scope := self queriedScope ifNil: [ self queriedClass ].
	
		^ SystemNavigation default 
			allMethodsSelect:  [ :m | 
			m
				hasLiteralSuchThat: [ :l | 
					l isString
						and: [ l isSymbol not
								and: [ l includesSubstring: aString caseSensitive: false ] ] ] ]

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
PowerlangWebsideAPI >> runtime [
	^ server resourcesAt: #runtime
]

{ #category : #private }
PowerlangWebsideAPI >> sendersOf: aSymbol [
	| scope |
	scope := self queriedScope.
	^ scope
		ifNotNil: [ self sendersOf: aSymbol among: scope methods ]
		ifNil: [ SystemNavigation default allSendersOf: aSymbol ]
]

{ #category : #private }
PowerlangWebsideAPI >> sendersOf: aSymbol among: aCollection [
	| index |
	index := Smalltalk specialSelectorIndexOrNil: aSymbol.
	^ aCollection
		select: [ :m | m hasSelector: aSymbol specialSelectorIndex: index ]
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
	^ class subclasses collect: [ :c | c asWebsideJson ]
]

{ #category : #private }
PowerlangWebsideAPI >> subclassesOf: aSpeciesMap [
	| image spec |
	image := self image.
	spec := image => aSpeciesMap name.
	^ spec subclasses
		collect: [ :c | image speciesFor: image => c name ]
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
