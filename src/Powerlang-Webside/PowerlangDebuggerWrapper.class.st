Class {
	#name : #PowerlangDebuggerWrapper,
	#superclass : #Object,
	#instVars : [
		'context'
	],
	#category : #'Powerlang-Webside-Base'
}

{ #category : #accessing }
PowerlangDebuggerWrapper >> context [
	^context
]

{ #category : #accessing }
PowerlangDebuggerWrapper >> context: anEvaluatorContext [

	context := anEvaluatorContext
]
