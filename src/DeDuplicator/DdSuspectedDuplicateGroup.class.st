Class {
	#name : #DdSuspectedDuplicateGroup,
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
DdSuspectedDuplicateGroup >> addMergabilityConditionsTo: aDescription [
	
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
DdSuspectedDuplicateGroup >> addValidityConditionsTo: aDescription [
	aDescription
		addCondition: [ :col | col size = 1 ] labelled: 'Only one instance';
		addCondition: [ :col | col allSatisfy: self canonInclusionTest ] labelled: 'Instance must be in canon'
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> canonInclusionTest [
	^ self client canonInclusionTest
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> canonical [
	^ self instances detect: self canonInclusionTest ifNone: [ nil ]
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> client [

	^ client
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> client: anObject [

	client := anObject
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> failedMergeConditions [
	
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
DdSuspectedDuplicateGroup >> fieldConditions [
	
	^ self client fieldConditions
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> groupConditions [
	
	^ self client groupConditions
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> gtViewInstancesOn: aView [

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
DdSuspectedDuplicateGroup >> gtViewMergeVerificationOn: aView [
	<gtView>
	| items |
	items := self failedMergeConditions ifEmpty: [ ^ aView empty ].
	^ aView list
		title: 'Merge Verification' translated;
		priority: 50;
		items: [ items ]
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> gtViewPatchOn: aView [
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
DdSuspectedDuplicateGroup >> id [

	^ id
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> id: anObject [

	id := anObject
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> instances [

	^ instances
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> instances: anObject [

	instances := anObject
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> isMergable [
	
	^ self failedMergeConditions isEmpty
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> isValid [
	| desc |
	desc := MAToManyRelationDescription new.
	self addValidityConditionsTo: desc.
	[ desc validateConditions: self instances ]
		on: MAValidationError
		do: [ :ex | ^ false ].
	^ true
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> merge [
	| duplicates canonical |
	self isMergable ifFalse: [ Warning signal: 'group not mergable!' ].
	canonical := self canonical.
	duplicates := self instances copyWithout: canonical.
	duplicates do: [ :e | e becomeForward: canonical ].
	self postMergeAction cull: self
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> patch [
	"Probably only makes sense if two instances"
	| col |
	col := self instances asOrderedCollection.
	col size < 2 ifTrue: [ ^ nil ].
	^ col first patchRelativeToBase: col second
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> postMergeAction [
	^ self client postMergeAction
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> printOn: aStream [

	aStream
		nextPut: $(;
		print: self instances size;
		nextPutAll: ' objects ';
		print: self id;
		nextPut: $)
]

{ #category : #accessing }
DdSuspectedDuplicateGroup >> statusIcon [

	self isValid ifTrue: [ ^ BrGlamorousIcons greencircle ].
	self isMergable ifTrue: [ ^ BrGlamorousIcons yellowcircle ].	
	^ BrGlamorousIcons redcircle
]
