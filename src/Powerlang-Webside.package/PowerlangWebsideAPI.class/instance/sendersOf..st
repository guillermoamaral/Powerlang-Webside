private
sendersOf: aSymbol
	| scope |
	scope := self queriedScope.
	^ scope
		ifNotNil: [ scope sendersOf: aSymbol ]
		ifNil: [ SystemNavigation default allSendersOf: aSymbol ]