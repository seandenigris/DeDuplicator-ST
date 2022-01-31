Class {
	#name : #BaselineOfDeDuplicator,
	#superclass : #BaselineOf,
	#category : #BaselineOfDeDuplicator
}

{ #category : #baselines }
BaselineOfDeDuplicator >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec 
			baseline: 'Magritte' with: [ 
				spec repository: 'github://seandenigris/Magritte' ];
			baseline: 'PharoEnhancements' with: [
				spec repository: 'github://seandenigris/Pharo-Enhancements' ].
		spec
			package: 'DeDuplicator' with: [
				spec requires: #('Magritte' 'PharoEnhancements'). ] ].
]

{ #category : #accessing }
BaselineOfDeDuplicator >> customProjectAttributes [

	^ self isGTImage
		ifTrue: [ #(GToolkit) ]
		ifFalse: [ #(notGToolkit) ].
]

{ #category : #testing }
BaselineOfDeDuplicator >> isGTImage [
	
	^ RPackageOrganizer default packageNames anySatisfy: [ :pn | pn beginsWith: 'Lepiter-' ].
	"Implementation note: used to check for GToolkit prefix, but P7 has a GToolkit-Examples package. Lepiter, OTOH, could only be loaded in a GT image"
]
