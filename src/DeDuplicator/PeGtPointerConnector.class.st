Class {
	#name : #PeGtPointerConnector,
	#superclass : #GtConnector,
	#instVars : [
		'generatedPointers'
	],
	#category : #DeDuplicator
}

{ #category : #'instance creation' }
PeGtPointerConnector class >> on: aCollection [

	^ aCollection 
		inject: self new 
		into: [ :result :e | 
			result 
				addNodeFor: e from: nil;
				yourself ].
]

{ #category : #accessing }
PeGtPointerConnector >> addNodeFor: modelObject from: sourceObject [
	| entity |
	entity := PeGtPointerNode new 
		model: modelObject;
		source: sourceObject;
		client: self;
		yourself.
	self addEntity: entity
]

{ #category : #accessing }
PeGtPointerConnector >> generatedPointers [

	^ generatedPointers ifNil: [ generatedPointers := PeGtPointerCollection new ]
]

{ #category : #accessing }
PeGtPointerConnector >> generatedPointers: anObject [

	generatedPointers := anObject
]

{ #category : #accessing }
PeGtPointerConnector >> hasGeneratedPointer: anObject [
	^ (self generatedPointers == anObject) 
		or: [ self generatedPointers identityIncludes: anObject ]
]

{ #category : #accessing }
PeGtPointerConnector >> initialize [

	super initialize.

	"Adapted from GtExample>>#gtConnectionsFor: and GtConnectorExamples>>#linearDependenciesWithButtonContainerExample"

	self stencil: [ :dataNode | dataNode asElement ].
]
