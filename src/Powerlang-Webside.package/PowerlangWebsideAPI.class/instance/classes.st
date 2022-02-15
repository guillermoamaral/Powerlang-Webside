code endpoints
classes
	| root tree classes names depth json |
	root := self queryAt: 'root'.
	root := root notNil
		ifTrue: [ self classNamed: root ]
		ifFalse: [ self defaultRootClass ].
	root ifNil: [ ^ self notFound ].
	tree := self queryAt: 'tree'.
	tree = 'true'
		ifTrue: [ depth := self queryAt: 'depth'.
			depth notNil
				ifTrue: [ depth := depth asInteger ].
			json := self classTreeFrom: root depth: depth.
			^ Array with: json ].
	classes := root withAllSubclasses.
	names := self queryAt: 'names'.
	names = 'true'
		ifTrue: [ ^ (classes collect: #name) sort ].
	^ classes collect: #asWebsideJson