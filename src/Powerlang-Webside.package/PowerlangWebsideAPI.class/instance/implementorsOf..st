private
implementorsOf: aSymbol
	| scope |
	scope := self queriedScope.
	^ scope
		ifNotNil: [ scope implementorsOf: aSymbol ]
		ifNil: [ SystemNavigation default allImplementorsOf: aSymbol ]