private
queriedReferencingClass
	| name |
	name := self queryAt: 'referencing'.
	^ name ifNotNil: [ self classNamed: name ]