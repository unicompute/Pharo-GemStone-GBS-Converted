Class {
	#name : 'GbsWorkspace',
	#superclass : 'SpPresenter',
	#instVars : [
		'textEditor'
	],
	#category : 'GemStone-GBS-Tools',
	#package : 'GemStone-GBS-Tools'
}

{ #category : 'layout' }
GbsWorkspace >> defaultLayout [
    ^ SpBoxLayout newVertical
        add: textEditor;
        yourself
]

{ #category : 'actions' }
GbsWorkspace >> executeInGemStone [
    | code result |
    code := textEditor selectedText.
    code ifEmpty: [ code := textEditor text ].
    code ifEmpty: [ ^ self ].
    
    [ 
        [ 
            result := GbsSessionParameters currentSession evaluate: code.
            result inspect.
        ] on: GbsError do: [ :ex | 
            (ex messageText includesSubstring: 'session ID is invalid') 
                ifTrue: [ self inform: 'GemStone Session expired. Please run the Login script again.' ]
                ifFalse: [ ex pass ]
        ]
    ] on: Error do: [ :ex | ex pass ].
]

{ #category : 'initialization' }
GbsWorkspace >> initialize [
    super initialize.
    "In Pharo 13, we ensure the code presenter is ready for interaction"
    textEditor 
        syntaxHighlight: true;
        beForObject: self.
    
    textEditor bindKeyCombination: $g command toAction: [ self executeInGemStone ].
    textEditor bindKeyCombination: $g control toAction: [ self executeInGemStone ].
]

{ #category : 'initialization' }
GbsWorkspace >> initializePresenters [
    textEditor := self newCode.
    
    "In Pharo 13, the method is #syntaxHighlight:"
    textEditor 
        syntaxHighlight: true;
        text: '"Type GemStone code here and press CMD+G to execute"
UserGlobals at: #PharoTime put: DateTime now.
UserGlobals at: #PharoTime'.
]

{ #category : 'initialization' }
GbsWorkspace >> initializeShortcutKeys [
    textEditor bindKeyCombination: $g command toAction: [ self executeInGemStone ].
    textEditor bindKeyCombination: $g control toAction: [ self executeInGemStone ].
]

{ #category : 'initialization' }
GbsWorkspace >> initializeWindow: aWindowPresenter [
    aWindowPresenter
        title: 'GemStone Workspace';
        initialExtent: 600@400.
]

{ #category : 'layout' }
GbsWorkspace >> staticLayout [
    ^ SpBoxLayout newVertical
        add: textEditor;
        yourself
]
