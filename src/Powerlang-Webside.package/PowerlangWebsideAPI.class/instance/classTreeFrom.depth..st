private
classTreeFrom: aClass depth: anInteger
	| json subclasses depth names |
	names := self queryAt: 'names'.
	json := names = 'true'
		ifTrue: [ NeoJSONObject new
				at: 'name' put: aClass name;
				at: 'superclass'
					put: (aClass superclass ifNotNil: [ :c | c name ]);
				yourself ]
		ifFalse: [ aClass asWebsideJson ].
	(anInteger notNil and: [ anInteger = 0 ])
		ifTrue: [ ^ json ].
	depth := anInteger notNil
		ifTrue: [ anInteger - 1 ].
	subclasses := (aClass subclasses sort: [ :a :b | a name <= b name ])
		collect: [ :c | self classTreeFrom: c depth: depth ].
	json at: 'subclasses' put: subclasses.
	^ json