private
requestedClass
	| name |
	name := self urlAt: 'name'.
	^ name ifNotNil: [ self classNamed: name ]