Class {
	#name : #DdGtPointerNode,
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
DdGtPointerNode >> = rhs [

	self species = rhs species ifFalse: [ ^ false ].
	^ self model == rhs model
]

{ #category : #accessing }
DdGtPointerNode >> asElement [
	^ DdGtPointerNodeElement on: self
]

{ #category : #accessing }
DdGtPointerNode >> client [

	^ client
]

{ #category : #accessing }
DdGtPointerNode >> client: anObject [

	client := anObject
]

{ #category : #accessing }
DdGtPointerNode >> displayStringOn: aStream [
	model ifNotNil: [ ^ model displayStringOn: aStream ].
	super displayStringOn: aStream
]

{ #category : #accessing }
DdGtPointerNode >> interestingPointersTo [
	| rejectedTypes rejectedPackagePrefixes rejectedClassNamePrefixes |
	rejectedTypes := { BlockClosure. Context. OpalCompiler }.
	rejectedPackagePrefixes := #('Brick' 'GT' 'GToolkit' 'Magritte' 'Lepiter' 'NewTools' 'Spec2').
	rejectedClassNamePrefixes := #('PeGtPointer').

	interestingPointersTo ifNotNil: [ ^ interestingPointersTo ].
	interestingPointersTo := (DdGtPointerCollection newFrom: self model interestingPointersTo).
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
DdGtPointerNode >> interestingPointersTo: anObject [

	interestingPointersTo := anObject
]

{ #category : #accessing }
DdGtPointerNode >> model [

	^ model
]

{ #category : #accessing }
DdGtPointerNode >> model: anObject [

	model := anObject
]

{ #category : #accessing }
DdGtPointerNode >> source [

	^ source
]

{ #category : #accessing }
DdGtPointerNode >> source: anObject [

	source := anObject
]

{ #category : #accessing }
DdGtPointerNode >> wasGeneratedByClient [
	^ self client hasGeneratedPointer: self model.
]
