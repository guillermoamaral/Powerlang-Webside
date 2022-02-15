code endpoints
testDialect
	| dialect |
	dialect := self get: 'dialect'.
	self assert: dialect equals: 'Powerlang-Ring'