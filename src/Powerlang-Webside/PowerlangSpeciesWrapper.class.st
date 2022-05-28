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

{ #category : #converting }
PowerlangSpeciesWrapper >> asWebsideJson [
	^ super asWebsideJson
		at: 'name' put: wrappee printString;
		at: 'definition' put: self definition;
		at: 'superclass'
			put:
			((self superclass != runtime nil) = runtime true
				ifTrue: [ self superclass name wrappee asLocalString ]);
		at: 'comment' put: self comment wrappee asLocalString;
		at: 'variable' put: false;
		at: 'project' put: '';
		yourself
]

{ #category : #private }
PowerlangSpeciesWrapper >> classVariablesString [
	^ String
		streamContents: [ :s | 
			self classVarNames asArray wrappee slots
				do: [ :n | s nextPutAll: n asLocalString ]
				separatedBy: [ s space ] ]
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> definition [
	| highest |
	^ String
		streamContents: [ :strm | 
			highest := self superclass wrappee = runtime nil.
			highest
				ifTrue: [ strm nextPutAll: 'ProtoObject' ]
				ifFalse: [ strm nextPutAll: self superclass name wrappee asLocalString ].
			strm
				space;
				nextPutAll: self kindOfSubclass wrappee asLocalString;
				space;
				store: self name wrappee asLocalString;
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
						nextPutAll: self name wrappee asLocalString;
						space;
						nextPutAll: 'superclass: nil' ] ]
]

{ #category : #private }
PowerlangSpeciesWrapper >> instanceVariablesString [
	^ String
		streamContents: [ :s | 
			self instVarNames asArray wrappee slots
				do: [ :n | s nextPutAll: n asLocalString ]
				separatedBy: [ s space ] ]
]

{ #category : #inquiries }
PowerlangSpeciesWrapper >> methods [
	| md |
	md := self methodDictionary.
	"^ md keys asSet asArray wrappee slots
		collect:
			[ :k | PowerlangMethodWrapper on: (md at: k) wrappee runtime: runtime ]"
	^ md wrappee slots second slots select: [ :o |  
		(runtime sendLocal: #isCompiledMethod to: o) = runtime true
		
		] thenCollect: [ :o |  PowerlangMethodWrapper on: o runtime: runtime]
]

{ #category : #private }
PowerlangSpeciesWrapper >> sharedPoolsString [
	^ String
		streamContents: [ :s | 
			self sharedPools asArray wrappee slots
				do: [ :n | s nextPutAll: n asLocalString ]
				separatedBy: [ s space ] ]
]