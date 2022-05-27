"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestPowerlangWebside,
	#superclass : #PackageManifest,
	#category : #'Powerlang-Webside-Manifest'
}

{ #category : #'code-critics' }
ManifestPowerlangWebside class >> ruleRBBadMessageRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#'Powerlang-Webside')) #'2022-05-27T22:04:23.077811+00:00') )
]
