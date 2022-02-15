private
delete: uri
	| data |
	data := client delete: server baseUrl / uri.
	^ data ifNotNil: [ NeoJSONObject fromString: data ]