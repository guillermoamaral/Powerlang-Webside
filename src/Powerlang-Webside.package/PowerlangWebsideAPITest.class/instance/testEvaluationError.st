evaluation  endpoints
testEvaluationError
	| evaluation error description |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + ';
		at: 'sync' put: true;
		yourself.
	self post: '/evaluations' with: evaluation.
	self deny: client isSuccess.
	error := NeoJSONObject fromString: client response entity string.
	description := (error at: 'description') asLowercase.
	self
		assert:
			(description includesSubstring: 'primary missing')
				| (description includesSubstring: 'variable or expression expected')