Class {
	#name : #PowerlangSpeciesWrapper,
	#superclass : #PowerlangObjectWrapper,
	#category : #'Powerlang-Webside-Base'
}

{ #category : #inquiries }
PowerlangSpeciesWrapper >> allSubclasses [
	^ super allSubclasses asArray wrappee slots
		collect: [ :c | PowerlangSpeciesWrapper on: c runtime: runtime ]
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> allSuperclasses [
	^ super allSuperclasses asArray wrappee slots
		collect: [ :c | PowerlangSpeciesWrapper on: c runtime: runtime ]
]

{ #category : #converting }
PowerlangSpeciesWrapper >> asWebsideJson [
	^ super asWebsideJson
		at: 'name' put: self name;
		at: 'definition' put: self definition;
		at: 'superclass'
			put:
			(self superclass wrappee != runtime nil
				ifTrue: [ self superclass name  ]);
		at: 'comment' put: self instanceClass comment;
		at: 'variable' put: false;
		at: 'project' put: '';
		yourself
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> categories [
	^ super categories asArray wrappee slots
		collect: [ :c | c asLocalString  ]
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> classVarNames [
	^ super classVarNames asArray wrappee slots
		collect: [ :s | s asLocalString ]
]

{ #category : #private }
PowerlangSpeciesWrapper >> classVariablesString [
	^ String
		streamContents: [ :s | 
			self classVarNames
				do: [ :n | s nextPutAll: n ]
				separatedBy: [ s space ] ]
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> comment [
	^ super comment wrappee asLocalString
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> definition [
	| highest |
	^ String
		streamContents: [ :strm | 
			highest := self superclass wrappee = runtime nil.
			highest
				ifTrue: [ strm nextPutAll: 'ProtoObject' ]
				ifFalse: [ strm nextPutAll: self superclass name ].
			strm
				space;
				nextPutAll: self kindOfSubclass wrappee asLocalString;
				space;
				store: self name;
				cr;
				tab;
				nextPutAll: 'instanceVariableNames: ';
				store: self instanceVariablesString;
				cr;
				tab;
				nextPutAll: 'classVariableNames: ';
				store: self classVariablesString;
				cr;
				tab;
				nextPutAll: 'poolDictionaries: ';
				store: self sharedPoolsString;
				cr;
				tab;
				nextPutAll: 'category: ';
				store: ''.
			highest
				ifTrue: [ strm
						nextPutAll: '.';
						cr;
						nextPutAll: self name;
						space;
						nextPutAll: 'superclass: nil' ] ]
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> instVarNames [
	^ super instVarNames asArray wrappee slots
		collect: [ :s |  s asLocalString]
]

{ #category : #private }
PowerlangSpeciesWrapper >> instanceVariablesString [
	^ String
		streamContents: [ :s | 
			self instVarNames
				do: [ :n | s nextPutAll: n  ]
				separatedBy: [ s space ] ]
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> methods [
	| md |
	md := self methodDictionary.
	^ md keys asSet asArray wrappee slots
		collect:
			[ :k | PowerlangMethodWrapper on: (md at: k) wrappee runtime: runtime ]
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> name [
	^super name wrappee asLocalString
]

{ #category : #private }
PowerlangSpeciesWrapper >> sharedPoolsString [
	^ String
		streamContents: [ :s | 
			self sharedPools asArray wrappee slots
				do: [ :n | s nextPutAll: n asLocalString ]
				separatedBy: [ s space ] ]
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> subclasses [
	^ super subclasses asArray wrappee slots
		collect: [ :c | PowerlangSpeciesWrapper on: c runtime: runtime ]
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> withAllSubclasses [
	^ OrderedCollection with: self withAll: self allSubclasses
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> withAllSuperclasses [
	^ OrderedCollection with:
		self withAll: self allSuperclasses
]
