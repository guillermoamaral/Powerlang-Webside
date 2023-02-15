Class {
	#name : #PowerlangMethodWrapper,
	#superclass : #PowerlangObjectWrapper,
	#category : #'Powerlang-Webside-Base'
}

{ #category : #converting }
PowerlangMethodWrapper >> asWebsideJson [

	^ super asWebsideJson
		  at: 'selector' put: self selector;
		  at: 'methodClass' put: self classBinding name;
		  at: 'category' put: 'self category';
		  at: 'source' put: self sourceCode;
		  at: 'author' put: 'self author';
		  at: 'timestamp' put: 'self timeStamp';
		  at: 'overriding' put: false;
		  at: 'overriden' put: false;
		  yourself
]

{ #category : #inquiries }
PowerlangMethodWrapper >> selector [
	^ super selector wrappee asLocalString
]

{ #category : #inquiries }
PowerlangMethodWrapper >> sourceCode [
	| source |
	source := self sourceObject wrappee.
	^source = runtime nil ifTrue: ['no source'] ifFalse: [source asLocalString]
]
