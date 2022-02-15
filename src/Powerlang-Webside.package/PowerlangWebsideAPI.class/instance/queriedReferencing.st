private
queriedReferencing
	^ self queriedReferencingClass ifNil: [ self queryAt: 'referencing' ]