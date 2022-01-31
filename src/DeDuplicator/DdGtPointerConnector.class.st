Class {
	#name : #DdGtPointerConnector,
	#superclass : #GtConnector,
	#instVars : [
		'generatedPointers'
	],
	#category : #DeDuplicator
}

{ #category : #'instance creation' }
DdGtPointerConnector class >> on: aCollection [

	^ aCollection 
		inject: self new 
		into: [ :result :e | 
			result 
				addNodeFor: e from: nil;
				yourself ].
]

{ #category : #accessing }
DdGtPointerConnector >> addNodeFor: modelObject from: sourceObject [
	| entity |
	entity := DdGtPointerNode new 
		model: modelObject;
		source: sourceObject;
		client: self;
		yourself.
	self addEntity: entity
]

{ #category : #accessing }
DdGtPointerConnector >> generatedPointers [

	^ generatedPointers ifNil: [ generatedPointers := DdGtPointerCollection new ]
]

{ #category : #accessing }
DdGtPointerConnector >> generatedPointers: anObject [

	generatedPointers := anObject
]

{ #category : #accessing }
DdGtPointerConnector >> hasGeneratedPointer: anObject [
	^ (self generatedPointers == anObject) 
		or: [ self generatedPointers identityIncludes: anObject ]
]

{ #category : #accessing }
DdGtPointerConnector >> initialize [

	super initialize.

	"Adapted from GtExample>>#gtConnectionsFor: and GtConnectorExamples>>#linearDependenciesWithButtonContainerExample"

	self stencil: [ :dataNode | dataNode asElement ].
]
