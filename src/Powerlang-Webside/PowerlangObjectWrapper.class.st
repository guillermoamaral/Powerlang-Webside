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

{ #category : #accessing }
PowerlangObjectWrapper >> doesNotUnderstand: aMessage [
	| result |
	result := runtime
		sendLocal: aMessage selector
		to: wrappee
		with: aMessage arguments.
	(result isKindOf: LMRObject)
		ifFalse: [ ^ result ].
	^ self class on: result runtime: runtime
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
