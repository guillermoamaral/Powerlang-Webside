private
queriedClass
	| name |
	name := request at: 'class' ifAbsent: nil.
	^ name ifNotNil: [ self classNamed: name ]