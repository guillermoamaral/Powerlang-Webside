Class {
	#name : #PowerlangWebsideObject,
	#superclass : #ProtoObject,
	#instVars : [
		'object',
		'runtime'
	],
	#category : #'Powerlang-Webside-Base'
}

{ #category : #'as yet unclassified' }
PowerlangWebsideObject class >> on: anLMRObject runtime: aPowerlangLMR [
	^self new object: anLMRObject ; runtime: aPowerlangLMR  
]

{ #category : #accessing }
PowerlangWebsideObject >> doesNotUnderstand: aMessage [
	| result |
	result := (object respondsTo: aMessage selector)
		ifTrue:
			[ object perform: aMessage selector withArguments: aMessage arguments ]
		ifFalse: [ object runtime
				sendLocal: aMessage selector
				to: object
				with: aMessage arguments ].
	(result isKindOf: LMRObject) ifFalse: [ ^result ].
	result = runtime nil
		ifTrue: [ ^ nil ].
	result = runtime true
		ifTrue: [ ^ true ].
	result = runtime false
		ifTrue: [ ^ false ].
	result := self class on: result runtime: runtime.
	result isString
		ifTrue: [ ^ result asLocalString ].
	(result isCollection and: [ result isSequenceable ])
		ifTrue: [ ^ 1
				to: result slots
				collect: [ :o | self class on: o runtime: runtime ] ].
	^ result
]

{ #category : #accessing }
PowerlangWebsideObject >> object: anLMRObject [ 
object:=anLMRObject 
]

{ #category : #accessing }
PowerlangWebsideObject >> runtime: aPowerlangLMR [
	runtime := aPowerlangLMR
]
