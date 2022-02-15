private
queriedScope
	| scope |
	scope := request at: 'scope' ifAbsent: nil.
	^ scope ifNotNil: [ self classNamed: scope ]