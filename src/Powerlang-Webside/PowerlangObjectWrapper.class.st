Class {
	#name : #PowerlangObjectWrapper,
	#superclass : #ProtoObject,
	#instVars : [
		'wrappee',
		'runtime'
	],
	#category : #'Powerlang-Webside-Base'
}

{ #category : #'instance creation' }
PowerlangObjectWrapper class >> on: anLMRObject runtime: aPowerlangLMR [ 
^self new wrappee: anLMRObject ; runtime: aPowerlangLMR 
]

{ #category : #converting }
PowerlangObjectWrapper >> asWebsideJson [
	| variable |
	variable := self objectClass isVariable wrappee = runtime true.
	^ NeoJSONObject new
		at: 'class' put: self name wrappee asLocalString;
		at: 'indexable' put: variable;
		at: 'size'
			put:
			(variable
				ifTrue: [ self size wrappee value ]
				ifFalse: [ 0 ]);
		at: 'printString' put: self printString;
		yourself
]

{ #category : #accessing }
PowerlangObjectWrapper >> doesNotUnderstand: aMessage [
	| arguments result class |
	arguments := aMessage arguments collect: [ :a | (a class == PowerlangObjectWrapper or: [ a class inheritsFrom: PowerlangObjectWrapper]) ifTrue: [a wrappee] ifFalse: [ a ]].
	result := runtime
		sendLocal: aMessage selector
		to: wrappee
		with: arguments.
	(result isKindOf: LMRObject)
		ifFalse: [ ^ result ].
	class := (runtime sendLocal: #isClass to: result) = runtime true
		ifTrue: [ PowerlangSpeciesWrapper ]
		ifFalse: [ PowerlangObjectWrapper ].
	^ class on: result runtime: runtime
]

{ #category : #inquiries }
PowerlangObjectWrapper >> object [
	^wrappee
]

{ #category : #inquiries }
PowerlangObjectWrapper >> objectClass [
	| class |
	class := runtime sendLocal: #class to: wrappee.
	^ PowerlangSpeciesWrapper on: class runtime: runtime
]

{ #category : #printing }
PowerlangObjectWrapper >> printString [
	^wrappee printString
]

{ #category : #accessing }
PowerlangObjectWrapper >> runtime: aPowerlangLMR [
	runtime := aPowerlangLMR
]

{ #category : #accessing }
PowerlangObjectWrapper >> wrappee [
	^wrappee 
]

{ #category : #accessing }
PowerlangObjectWrapper >> wrappee: anLMRObject [
	wrappee := anLMRObject
]
