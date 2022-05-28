Class {
	#name : #PowerlangMethodWrapper,
	#superclass : #PowerlangObjectWrapper,
	#category : #'Powerlang-Webside-Base'
}

{ #category : #converting }
PowerlangMethodWrapper >> asWebsideJson [
	^ super asWebsideJson
		at: 'selector' put: self selector wrappee asLocalString ;
		at: 'class' put: self classBinding name wrappee asLocalString;
		at: 'category' put: 'self category';
		at: 'source' put: 'self sourceCode';
		at: 'author' put: 'self author';
		at: 'timestamp' put: 'self timeStamp';
		at: 'overriding' put: false;
		at: 'overriden' put: false;
		yourself
]