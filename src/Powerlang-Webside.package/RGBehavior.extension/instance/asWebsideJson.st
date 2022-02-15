*Powerlang-Webside
asWebsideJson
	^ super asWebsideJson
		at: 'name' put: self name;
		at: 'definition' put: self definition;
		at: 'superclass' put: (self superclass ifNotNil: [ :c | c name ]);
		at: 'comment' put: self comment asString;
		at: 'variable' put: self isVariable;
		at: 'project' put: self package name;
		yourself