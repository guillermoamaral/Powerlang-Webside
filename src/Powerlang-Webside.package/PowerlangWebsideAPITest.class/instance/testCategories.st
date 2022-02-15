code endpoints
testCategories
	| categories |
	categories := self get: 'classes/Point/categories'.
	self
		assert: categories notEmpty;
		assert: (categories allSatisfy: #isString);
		assert: (categories includes: 'arithmetic')
		
  