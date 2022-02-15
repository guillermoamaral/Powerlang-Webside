private
classNamed: aString
	| name metaclass class |
	name := aString.
	metaclass := name endsWith: ' class'.
	metaclass
		ifTrue: [ name := name withoutSuffix: ' class' ].
	class := runtime image => name.
	^ metaclass
		ifTrue: [ class metaclass ]
		ifFalse: [ class ]