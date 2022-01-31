Class {
	#name : #SpSuspectedDuplicateGroup,
	#superclass : #Object,
	#traits : 'MATPropertyOwner',
	#classTraits : 'MATPropertyOwner classTrait',
	#instVars : [
		'instances',
		'id',
		'client'
	],
	#category : #DeDuplicator
}

{ #category : #accessing }
SpSuspectedDuplicateGroup >> addMergabilityConditionsTo: aDescription [
	
	aDescription
		addCondition: [ :col | col size > 1 ]
			labelled: 'Must have multiple instances';
		addCondition: [ :col | (col select: self canonInclusionTest) size = 1 ]
			labelled: 'Must be exactly one canonical'.
	
	self fieldConditions do: [ :assoc |
		aDescription
			addCondition: [ :col | 
				| seed |
				seed := col atRandom perform: assoc key.
				col allSatisfy: [ :e | assoc value cull: e cull: seed ] ]
			labelled: assoc key ].
	
	"self instances size < 2 ifTrue: [ ^ self ]."
	
	self groupConditions do: [ :valuable |
		aDescription
			addCondition: [ :col | valuable cull: self instances cull: self ]
				labelled: valuable printString ]
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> addValidityConditionsTo: aDescription [
	aDescription
		addCondition: [ :col | col size = 1 ] labelled: 'Only one instance';
		addCondition: [ :col | col allSatisfy: self canonInclusionTest ] labelled: 'Instance must be in canon'
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> canonInclusionTest [
	^ self client canonInclusionTest
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> canonical [
	^ self instances detect: self canonInclusionTest ifNone: [ nil ]
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> client [

	^ client
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> client: anObject [

	client := anObject
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> failedMergeConditions [
	
	^ OrderedCollection streamContents: [ :str |
		[ 
			| desc |
			desc := MAToManyRelationDescription new.
			self addMergabilityConditionsTo: desc.
			desc validateConditions: self instances ]
				on: MAValidationError
				do: [ :ex | str << ex. ex resume ] ].
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> fieldConditions [
	
	^ self client fieldConditions
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> groupConditions [
	
	^ self client groupConditions
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> gtViewInstancesOn: aView [

	<gtView>
	^ aView columnedList
		title: 'Instances' translated;
		priority: 65;
		items: [ self instances asOrderedCollection ];
		column: 'Status' 
			icon: [ :e | self client statusIconFor: e ]
			width: 75;
		column: 'Name' text: [ :p | p asString asRopedText ];
		"column: 'Actions' 
			icon: [ :p | p actionButtons first ]
			width: 500;"
		actionUpdateButtonTooltip: 'Update'
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> gtViewMergeVerificationOn: aView [
	<gtView>
	| items |
	items := self failedMergeConditions ifEmpty: [ ^ aView empty ].
	^ aView list
		title: 'Merge Verification' translated;
		priority: 50;
		items: [ items ]
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> gtViewPatchOn: aView [
	<gtView>
	self patch 
		ifNotNil: [ :p |
			p operations ifEmpty: [ ^ aView empty ] ]
		ifNil: [ ^ aView empty ].
	^ aView explicit
		title: 'Patch' translated;
		priority: 51;
		stencil: [ self patch asElement ]
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> id [

	^ id
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> id: anObject [

	id := anObject
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> instances [

	^ instances
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> instances: anObject [

	instances := anObject
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> isMergable [
	
	^ self failedMergeConditions isEmpty
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> isValid [
	| desc |
	desc := MAToManyRelationDescription new.
	self addValidityConditionsTo: desc.
	[ desc validateConditions: self instances ]
		on: MAValidationError
		do: [ :ex | ^ false ].
	^ true
]

{ #category : #accessing }
SpSuspectedDuplicateGroup >> merge [
	| duplicates canonical |
	self isMergable ifFalse: [ Warning signal: 'group not mergable!' ].
	canonical := self canonical.
	duplicates := self instances copyWithout: canonical.
	duplicates do: [ :e | e becomeForward: canonical ].
	self postMergeAction cull: self
]