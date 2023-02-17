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

	| runtime |
	runtime := (PowertalkRingImage fromSpec
		            wordSize: 8;
		            genesis;
		            bootstrap;
		            fillClasses;
		            fillSymbols;
		            generateLMR) result.
	^ WebsideServer new
		  apiClass: PowerlangWebsideAPI;
		  baseUri: '/powerlang';
		  port: 9010;
		  resourcesAt: #runtime put: runtime;
		  start
]

{ #category : #services }
PowerlangWebsideAPI class >> stopServer [
	"
	self stopServer
	"

	WebsideServer allInstances do: #stop
]

{ #category : #'changes endpoints' }
PowerlangWebsideAPI >> addChange [

	| change author |
	change := self requestedChange.
	change ifNil: [ ^ self badRequest: 'Change not supported' ].
	author := self bodyAt: 'author' ifAbsent: [ 'Unknown' ].
	[ self applyChange: change ]
		on: Error , SyntaxErrorNotification , OCUndeclaredVariableWarning
		do: [ :e | ^ self compilationError: e ].
	server changes add: change.
	^ change asWebsideJson
]

{ #category : #'private - changes' }
PowerlangWebsideAPI >> applyAddClassChange: aRBAddClassChange [
]

{ #category : #'private - changes' }
PowerlangWebsideAPI >> applyAddMethodChange: aRBAddMethodChange [

	| class method  |
	class := self classNamed: aRBAddMethodChange changeClassName.
	class ifNil: [ self error: 'Unexisting class' ].
	method := RGMethodDefinition new sourceCode:
		          aRBAddMethodChange source.
	self runtime bootstrapper createNewMethod: method in: class wrappee
]

{ #category : #'private - changes' }
PowerlangWebsideAPI >> applyChange: change [

	(change isKindOf: RBAddClassChange) ifTrue: [ 
		^ self applyAddClassChange: change ].
	(change isKindOf: RBAddMethodChange) ifTrue: [ 
		^ self applyAddMethodChange: change ].
	(change isKindOf: RBRemoveMethodChange) ifTrue: [ 
		^ self applyRemoveMethodChange: change ].
	self error: 'Change not supported'
]

{ #category : #'private - changes' }
PowerlangWebsideAPI >> applyRemoveMethodChange: aRBRemoveMethodChange [

]

{ #category : #private }
PowerlangWebsideAPI >> bodyAt: aString ifAbsent: aBlock [

	| json |
	json := NeoJSONReader fromString: request entity.
	^ json at: aString ifAbsent: aBlock
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

	| name metaclass root class |
	name := aString.
	metaclass := name endsWith: ' class'.
	metaclass ifTrue: [ name := name withoutSuffix: ' class' ].
	root := self defaultRootClass.
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
PowerlangWebsideAPI >> compilationError: error [

	| entity json suggestions |
	json := error asWebsideJson.
	(error isKindOf: OCUndeclaredVariableWarning) ifTrue: [ 
		suggestions := self declareVariableSuggestionsFrom: error.
		suggestions ifNotNil: [ json at: 'suggestions' put: suggestions ] ].
	entity := ZnStringEntity
		          with: (NeoJSONWriter toString: json)
		          type: (ZnMimeType applicationJson
				           charSet: 'utf-8';
				           yourself).
	^ (ZnResponse statusCode: 409) entity: entity
]

{ #category : #private }
PowerlangWebsideAPI >> defaultRootClass [

	| runtime root |
	runtime := self runtime.
	root := (PowerlangObjectWrapper on: runtime nil runtime: runtime)
		        objectClass.
	[ root superclass wrappee == runtime nil ] whileFalse: [ 
		root := root superclass ].
	^ root
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
	| scope root |
	scope := self queriedScope.
	scope
		ifNotNil: [ self halt. ^scope implementorsOf: aSymbol].
	root := self defaultRootClass.
	^root withAllSubclasses
		  select: [ :class | class includesSelector: aSymbol ]
		  thenCollect: [ :class | class >> aSymbol ]
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
	(class includesSelector: selector) ifFalse: [ ^ self notFound ].
	^ (class >> selector) asWebsideJson
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> methods [

	| selector methods senders global references class |
	selector := self queriedSelector.
	selector notNil ifTrue: [ methods := self implementorsOf: selector ].
	selector := self queriedSending.
	selector notNil ifTrue: [ 
		senders := self sendersOf: selector.
		methods := methods
			           ifNil: [ senders ]
			           ifNotNil: [ methods intersection: senders ] ].
	global := self queriedReferencingClass.
	global notNil ifTrue: [ 
		references := self referencesTo: global.
		methods := methods
			           ifNil: [ references ]
			           ifNotNil: [ methods intersection: references ] ].
	class := self requestedClass ifNil: [ self queriedClass ].
	(class notNil and: [ methods notNil ]) ifTrue: [ 
		methods := methods select: [ :m | m classBinding = class ] ].
	methods ifNil: [ 
		methods := (class ifNil: [ self defaultRootClass ]) methods ].
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
PowerlangWebsideAPI >> requestedChange [

	| json change |
	json := NeoJSONReader fromString: request entity.
	change := RBRefactoryChange fromWebsideJson: json.
	change ifNil: [ change := RBRefactoring fromWebsideJson: json ].
	^ change
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
	scope ifNotNil: [ 
		self halt.
		^ self sendersOf: aSymbol among: scope methods ].
	^ self defaultRootClass withAllSubclasses gather: [ :class | self halt ]
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
