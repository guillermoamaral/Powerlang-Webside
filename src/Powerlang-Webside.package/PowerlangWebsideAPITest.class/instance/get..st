private
get: uri
	| url data |
	url := server baseUrl asString.
	(uri beginsWith: '/') ifFalse: [ url := url , '/' ].
	url := url , uri.
	data := client get: url.
	client isNotFound
		ifTrue: [ ^ nil ].
	^ data ifNotNil: [ NeoJSONObject fromString: data ]