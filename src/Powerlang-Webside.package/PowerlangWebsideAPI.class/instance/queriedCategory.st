private
queriedCategory
	| category |
	category := request at: 'category' ifAbsent: nil.
	^ category ifNotNil: [ category asSymbol ]