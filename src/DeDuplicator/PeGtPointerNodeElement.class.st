Class {
	#name : #PeGtPointerNodeElement,
	#superclass : #BlElement,
	#instVars : [
		'model'
	],
	#category : #DeDuplicator
}

{ #category : #'instance creation' }
PeGtPointerNodeElement class >> on: aPeGtPointerNode [
	^ self basicNew
		model: aPeGtPointerNode;
		initialize
]

{ #category : #accessing }
PeGtPointerNodeElement >> addTooltipTo: aBlElement [
	| tip |
	tip := [ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularFontAndSize);
		padding: (BlInsets all: 20);
		text: self model model fullDisplayString;
		alignCenter ].
	aBlElement addAptitude: (BrGlamorousWithTooltipAptitude content: tip)
]

{ #category : #accessing }
PeGtPointerNodeElement >> initialize [
	| connectorSource |
	super initialize.
	
	self initializeContainer: self.
	
	self
		background: (Color gray alpha: 0.1);
		border: (BlBorder paint: (Color blue alpha: 0.2) width: 2).
		
	self connector
		model: model;
		beLayoutSource;
		beLayoutTarget;
		beVisualTarget.
			
	connectorSource := BlElement new.
	self initializeContainer: connectorSource.
	
	self model source ifNotNil: [ :source |
		"Adapted from treeDependeciesExampleWithNoVisualSourceAndNoExplicitReferences"
		connectorSource connector 
			model: source;
			beVisualSource ].

	connectorSource
		addChild: self newConnectButton;
		addChild: (self newButtonLabelled: (self model displayStringLimitedTo: 24) action: [ :button | button phlow spawnObject: self model ]).
		
	self addTooltipTo: self.
	
	self addChild: connectorSource
]

{ #category : #accessing }
PeGtPointerNodeElement >> initializeContainer: anElement [
	anElement
		geometry: (BlRoundedRectangleGeometry cornerRadius: 5);
		clipChildren: false;
		layout: BlFrameLayout new;
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c vertical fitContent ];
		yourself 
]

{ #category : #accessing }
PeGtPointerNodeElement >> model [
	^ model
]

{ #category : #accessing }
PeGtPointerNodeElement >> model: aPeGtPointerNode [
	model := aPeGtPointerNode
]

{ #category : #accessing }
PeGtPointerNodeElement >> newButtonLabelled: aString action: aBlock [
	^ BrButton new
		aptitude: BrTextLabelAptitude;
		label: aString;
		layout: BlFrameLayout new;
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c vertical fitContent ];
		action: aBlock;
		yourself
]

{ #category : #accessing }
PeGtPointerNodeElement >> newConnectButton [

	^ (GtInspectorRoundButtonStencil new size: 15 @ 15) asElement
		icon: BrPlusIconStencil close asElement;
		constraintsDo: [ :c | 
			c ignoreByLayout.
			c margin: (BlInsets
				top: -7.5
				left: 0
				bottom: 0
				right: -7.5).
			c ignored horizontal alignRight.
			c ignored vertical alignTop ];
		action: [ :aButton | self onConnect ]
]

{ #category : #accessing }
PeGtPointerNodeElement >> onConnect [
	self model interestingPointersTo 
		ifNotEmpty: [ :ips | ips do: [ :ip | self model client addNodeFor: ip from: self model ] ]
		ifEmpty: [ self border: (BlBorder paint: (Color red alpha: 0.2) width: 2) ]
]
