private
referencesTo: aClass
	| binding |
	binding := Smalltalk bindingOf: aClass name asSymbol.
	^ SystemNavigation default allReferencesTo: binding