private
queriedSending
	| selector |
	selector := request at: 'sending' ifAbsent: nil.
	^ selector ifNotNil: [ selector asSymbol ]