"
| image |
image := PowertalkRingImage fromSpec
		wordSize: 8;
		genesis;
		bootstrap;
		fillClasses;
		fillSymbols;
		generateLMR.

WebsideServer new
		apiClass: PowerlangWebsideAPI;
		baseUri: '/powerlang';
		port: 9002;
		resourcesAt: #runtime put: runtime;
		start.
		

WebsideServer allInstances anyone.
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
	runtime := PowertalkRingImage fromSpec
		wordSize: 8;
		genesis;
		bootstrap;
		fillClasses;
		fillSymbols;
		generateLMR.
	^WebsideServer new
		apiClass: PowerlangWebsideAPI;
		baseUri: '/powerlang';
		port: 9002;
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

{ #category : #private }
PowerlangWebsideAPI >> allSubclassesOf: anLMRObject [
	^ (self runtime sendLocal: #allSubclasses to: anLMRObject) slots last
		slots
]

{ #category : #'code endpoints' }
PowerlangWebsideAPI >> categories [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ class instanceSpec protocols
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
	| runtime class highest |
	runtime := self runtime.
	class := PowerlangObjectWrapper2 on: runtime nil runtime: runtime.
	highest := [ class = runtime nil ]
		whileFalse: [ class := class superclass ].
	^highest allSubclasses
		detect: [ :c | c name  = aString ]
		ifNone: nil
]

{ #category : #private }
PowerlangWebsideAPI >> classTreeFrom: aSpeciesMap depth: anInteger [
	| json subclasses depth names |
	names := self queryAt: 'names'.
	json := names = 'true'
		ifTrue: [ NeoJSONObject new
				at: 'name' put: aSpeciesMap name;
				at: 'superclass'
					put: (aSpeciesMap superclass ifNotNil: [ :c | c name ]);
				yourself ]
		ifFalse: [ aSpeciesMap asWebsideJson ].
	(anInteger notNil and: [ anInteger = 0 ])
		ifTrue: [ ^ json ].
	depth := anInteger notNil
		ifTrue: [ anInteger - 1 ].
	subclasses := ((self subclassesOf: aSpeciesMap)
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
			| slots |
			slots := c classVariables slots.
			slots isEmpty
				ifTrue: [ #() ]
				ifFalse: [ slots first keys slots
						collect: [ :v | 
							NeoJSONObject new
								at: 'name' put: v asString;
								at: 'class' put: c name , ' class';
								yourself ] ] ]
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
	classes := Array with: root withAll: (self allSubclassesOf: root).
	names := self queryAt: 'names'.
	names = 'true'
		ifTrue: [ ^ (classes collect: #name) sort ].
	^ classes collect: [:c | self jsonOfClass: c]
]

{ #category : #private }
PowerlangWebsideAPI >> defaultRootClass [
	^ self  classNamed: 'Object'
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
			c instanceVariables slots
				collect: [ :v | 
					NeoJSONObject new
						at: 'name' put: v asString;
						at: 'class' put: c name;
						yourself ] ]
]

{ #category : #private }
PowerlangWebsideAPI >> jsonOfClass: anLMRObject [ 
	^NeoJSONObject new
		at: 'name' put: anLMRObject name;
		at: 'definition' put: anLMRObject oldDefinition;
		at: 'superclass' put: (anLMRObject superclass ifNotNil: [ :c | c name ]);
		at: 'comment' put: anLMRObject comment;
		at: 'variable' put: anLMRObject isVariable;
		at: 'project' put: anLMRObject package name;
		yourself
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
PowerlangWebsideAPI >> runtime [
	^ server resourcesAt: #runtime
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
