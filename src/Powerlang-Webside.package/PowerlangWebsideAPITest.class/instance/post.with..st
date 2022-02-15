private
post: uri with: body
	| data |
	data := client post: server baseUrl / uri contents: body asString.
	^ NeoJSONObject fromString: data