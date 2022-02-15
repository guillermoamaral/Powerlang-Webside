private
queriedSelector
	| selector |
	selector := request at: 'selector' ifAbsent: nil.
	^ selector ifNotNil: [ selector asSymbol ]