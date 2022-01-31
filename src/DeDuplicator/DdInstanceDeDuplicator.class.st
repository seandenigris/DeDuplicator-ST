"
I help visualize models where the object references have been broken, causing model fragmentation and duplicate instances. This can happen due to incorrect serialization/materialization.

For example, if your model graph root was `{ A. B }`, where:
	A -> B
	C -> B
You might end up with:
	A -> B
	C -> B'
There are now two different copies of B.

I will show you which instances are probably duplicates and which are okay. Check out this example: {{gtExample:SpInstanceDeDuplicator class>>#example}}
"
Class {
	#name : #DdInstanceDeDuplicator,
	#superclass : #Object,
	#instVars : [
		'objects',
		'groups',
		'canonInclusionTest',
		'fieldConditions',
		'groupConditions',
		'idBlock',
		'postMergeAction'
	],
	#category : #DeDuplicator
}

{ #category : #examples }
DdInstanceDeDuplicator class >> example [
	<gtExample>
	
	| canon objs |
	^ self
		given: [ 
			canon := { 1@1. 2@2 }.
			objs := OrderedCollection new
				addAll: canon;
				add: canon atRandom copy;
				add: 3@3;
				yourself ]
		when: [ 
			(DdInstanceDeDuplicator forObjects: objs)
				canonInclusionTest: [ :e | canon identityIncludes: e ];
				idBlock: [ :e | e printString ];
				yourself ]
		then: [ :d |
			d selectMergable groups should haveSize: 1.
			d selectValid groups should haveSize: canon size - 1.
			d selectUnmergable groups should haveSize: 1 ]
]

{ #category : #accessing }
DdInstanceDeDuplicator class >> forObjects: aCollection [ 
	^ self new
		objects: aCollection;
		yourself
]

{ #category : #accessing }
DdInstanceDeDuplicator >> autoMerge [
	self selectMergable groups do: #merge
]

{ #category : #accessing }
DdInstanceDeDuplicator >> canonInclusionTest [

	^ canonInclusionTest
]

{ #category : #accessing }
DdInstanceDeDuplicator >> canonInclusionTest: anObject [

	canonInclusionTest := anObject
]

{ #category : #accessing }
DdInstanceDeDuplicator >> childrenFor: anObject [

	(anObject isKindOf: DdSuspectedDuplicateGroup) ifTrue: [ 
		^ anObject instances ].
	^ #()
]

{ #category : #accessing }
DdInstanceDeDuplicator >> copyForObjects: aCollection [
	^ (self class forObjects: aCollection)
		idBlock: self idBlock;
		canonInclusionTest: self canonInclusionTest;
		groupConditions: self groupConditions;
		fieldConditions: self fieldConditions;
		yourself
		
]

{ #category : #accessing }
DdInstanceDeDuplicator >> copySelect: aBlock [

	| selectedGroups objs |
	selectedGroups := self groups select: aBlock.
	objs := (selectedGroups flatCollect: #instances) asIdentitySet.
	^ self copyForObjects: objs
]

{ #category : #accessing }
DdInstanceDeDuplicator >> fieldConditions [

	^ fieldConditions ifNil: [ 
		{ 
			#yourself -> [ :r | true ] 
		} ].
]

{ #category : #accessing }
DdInstanceDeDuplicator >> fieldConditions: anObject [

	fieldConditions := anObject
]

{ #category : #accessing }
DdInstanceDeDuplicator >> groupConditions [

	^ groupConditions ifNil: [ 
		{ 
			[ :insts :grp | 
				| oCol |
				oCol := grp instances asOrderedCollection.
				oCol size > 1 
					ifTrue: [ (oCol first patchRelativeToBase: oCol second) operations isEmpty ]
					ifFalse: [ true ] ]
		} ]
]

{ #category : #accessing }
DdInstanceDeDuplicator >> groupConditions: anObject [

	groupConditions := anObject
]

{ #category : #accessing }
DdInstanceDeDuplicator >> groups [
	| dict |
	groups ifNotNil: [ ^ groups ].
	dict := self objects groupedBy: self idBlock.
	^ groups := OrderedCollection streamContents: [ :str |
		dict keysAndValuesDo: [ :k :v |
			| group |
			group := DdSuspectedDuplicateGroup new
				client: self;
				id: k;
				instances: v;
				yourself.
			str nextPut: group ] ].
]

{ #category : #accessing }
DdInstanceDeDuplicator >> gtViewTreeOn: aView [
	<gtView>
	^ aView columnedTree
		title: 'Objects' translated;
		priority: 80;
		items: [ self groups ];
		children: [ :e | self childrenFor: e ]; 
		column: 'Status' 
			icon: [ :e | self statusIconFor: e ]
			width: 75;
		column: 'Name' text: [ :p | p asString asRopedText ];
		"column: 'Actions' 
			icon: [ :p | p actionButtons first ]
			width: 500;"
		actionUpdateButtonTooltip: 'Update'
]

{ #category : #accessing }
DdInstanceDeDuplicator >> idBlock [

	^ idBlock
]

{ #category : #accessing }
DdInstanceDeDuplicator >> idBlock: anObject [

	idBlock := anObject
]

{ #category : #accessing }
DdInstanceDeDuplicator >> includedClasses [
	^ self objects collect: #class as: Set
]

{ #category : #accessing }
DdInstanceDeDuplicator >> objects [

	^ objects
]

{ #category : #accessing }
DdInstanceDeDuplicator >> objects: anObject [

	objects := anObject
]

{ #category : #accessing }
DdInstanceDeDuplicator >> postMergeAction [

	^ postMergeAction ifNil: [ postMergeAction := [ :grp | ] ]
]

{ #category : #accessing }
DdInstanceDeDuplicator >> postMergeAction: anObject [

	postMergeAction := anObject
]

{ #category : #accessing }
DdInstanceDeDuplicator >> printOn: aStream [

	aStream
		print: self groups size;
		nextPutAll: ' groups'
]

{ #category : #accessing }
DdInstanceDeDuplicator >> reset [
	groups := nil
]

{ #category : #accessing }
DdInstanceDeDuplicator >> selectMergable [

	^ self copySelect: #isMergable
]

{ #category : #accessing }
DdInstanceDeDuplicator >> selectUnmergable [

	^ self copySelect: [ :e | e isMergable not and: [ e isValid not ] ]
]

{ #category : #accessing }
DdInstanceDeDuplicator >> selectValid [

	^ self copySelect: #isValid
]

{ #category : #accessing }
DdInstanceDeDuplicator >> statusIconFor: anObject [
	
	(anObject isKindOf: DdSuspectedDuplicateGroup) ifTrue: [ 
		^ anObject statusIcon ].
			
	^ (self canonInclusionTest value: anObject)
		ifTrue: [ BrGlamorousIcons greencircle ]
		ifFalse: [ BrGlamorousIcons redcircle ].
]
