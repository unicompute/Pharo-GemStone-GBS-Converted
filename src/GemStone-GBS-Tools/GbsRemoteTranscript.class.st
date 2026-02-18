Class {
	#name : 'GbsRemoteTranscript',
	#superclass : 'SpPresenter',
	#instVars : [
		'textPresenter',
		'pollingProcess'
	],
	#category : 'GemStone-GBS-Tools',
	#package : 'GemStone-GBS-Tools'
}

{ #category : 'layout' }
GbsRemoteTranscript >> defaultLayout [
    ^ SpBoxLayout newVertical add: textPresenter; yourself
]

{ #category : 'logic' }
GbsRemoteTranscript >> fetchLogs [
    | logs |
    [
        "Call the new custom method we just installed"
        logs := GbsSessionParameters currentSession evaluate: 'Transcript fetchAndClear'.
            
        (logs isNotNil and: [ logs isNotEmpty ]) ifTrue: [ 
            textPresenter text: (textPresenter text, logs).
            textPresenter scrollToEnd.
        ]
    ] on: Error do: [ :ex | "Ignore polling errors" ]
]

{ #category : 'initialization' }
GbsRemoteTranscript >> initializePresenters [
    textPresenter := self newText.
    textPresenter beNotEditable.
]

{ #category : 'initialization' }
GbsRemoteTranscript >> initializeWindow: aWindowPresenter [
    aWindowPresenter 
        title: 'GemStone Remote Transcript';
        initialExtent: 500@300.
]

{ #category : 'logic' }
GbsRemoteTranscript >> startPolling [
    pollingProcess ifNotNil: [ pollingProcess terminate ].
    pollingProcess := [ 
        [ self window isNotNil and: [ self window isOpen ] ] whileTrue: [ 
            self fetchLogs.
            (Delay forSeconds: 2) wait.
        ] 
    ] fork.
]
