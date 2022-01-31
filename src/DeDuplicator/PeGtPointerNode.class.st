Class {
	#name : #PeGtPointerNode,
	#superclass : #Object,
	#instVars : [
		'source',
		'model',
		'interestingPointersTo',
		'client'
	],
	#category : #DeDuplicator
}

{ #category : #accessing }
PeGtPointerNode >> = rhs [

	self species = rhs species ifFalse: [ ^ false ].
	^ self model == rhs model
]

{ #category : #accessing }
PeGtPointerNode >> asElement [
	^ PeGtPointerNodeElement on: self
]

{ #category : #accessing }
PeGtPointerNode >> client [

	^ client
]

{ #category : #accessing }
PeGtPointerNode >> client: anObject [

	client := anObject
]

{ #category : #accessing }
PeGtPointerNode >> displayStringOn: aStream [
	model ifNotNil: [ ^ model displayStringOn: aStream ].
	super displayStringOn: aStream
]

{ #category : #accessing }
PeGtPointerNode >> interestingPointersTo [
	| rejectedTypes rejectedPackagePrefixes rejectedClassNamePrefixes |
	rejectedTypes := { BlockClosure. Context. OpalCompiler }.
	rejectedPackagePrefixes := #('Brick' 'GT' 'GToolkit' 'Magritte' 'Lepiter' 'NewTools' 'Spec2').
	rejectedClassNamePrefixes := #('PeGtPointer').

	interestingPointersTo ifNotNil: [ ^ interestingPointersTo ].
	interestingPointersTo := (PeGtPointerCollection newFrom: self model interestingPointersTo).
	"self client generatedPointers add: interestingPointersTo."
	interestingPointersTo := interestingPointersTo reject: [ :e | 
		(rejectedClassNamePrefixes anySatisfy: [ :str | e class name beginsWith: str ]) 
			"or: [ (rejectedPackagePrefixes anySatisfy: [ :cls | e isKindOf: cls])
				or: [ (rejectedTypes anySatisfy: [ :pkgPre | e class category beginsWith: pkgPre ]) "
					or: [ self client hasGeneratedPointer: e ] ] "] ]".
	"self client generatedPointers add: interestingPointersTo."
	^ interestingPointersTo
]

{ #category : #accessing }
PeGtPointerNode >> interestingPointersTo: anObject [

	interestingPointersTo := anObject
]

{ #category : #accessing }
PeGtPointerNode >> model [

	^ model
]

{ #category : #accessing }
PeGtPointerNode >> model: anObject [

	model := anObject
]

{ #category : #accessing }
PeGtPointerNode >> source [

	^ source
]

{ #category : #accessing }
PeGtPointerNode >> source: anObject [

	source := anObject
]

{ #category : #accessing }
PeGtPointerNode >> wasGeneratedByClient [
	^ self client hasGeneratedPointer: self model.
]
