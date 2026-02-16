Class {
	#name : 'GbsSession',
	#superclass : 'Object',
	#instVars : [
		'activeInteractions',
		'causeOfDeath',
		'clientTimeZone',
		'configuration',
		'dependents',
		'dirtyPool',
		'eventHandlers',
		'eventDetectorErrorHandler',
		'freeOops',
		'gbsm',
		'gemTimeZone',
		'gsClassOrganizer',
		'isRemote',
		'isUnwindingAsyncAbort',
		'nestingLevel',
		'notCachedToken',
		'parameters',
		'procBalancer',
		'replicatorManager',
		'serverInterface',
		'serverMap',
		'sessionDisplayString',
		'sessionId',
		'sessionProtect',
		'specialConverter',
		'stats',
		'asyncAbortStartAction',
		'asyncAbortFinishAction',
		'loginTimestamp',
		'logoutTimestamp',
		'gemProcessId',
		'gemSerialNumber',
		'gemSessionId'
	],
	#category : 'GemStone-GBS-Converted',
	#package : 'GemStone-GBS-Converted'
}

{ #category : 'as yet unclassified' }
GbsSession class >> loginWithUser: aUser password: aPass stone: aStone [
    | interface sessionID servicePtr userPtr passPtr |
    interface := GbsServerInterface uniqueInstance.
    interface apiGciInit.
    
    servicePtr := ExternalAddress fromString: aStone.
    userPtr := ExternalAddress fromString: aUser.
    passPtr := ExternalAddress fromString: aPass.
    
    [
        sessionID := interface apiGciLogin: servicePtr user: userPtr pass: passPtr.
        sessionID = 0 ifTrue: [ ^ nil ].
        
        ^ self new 
            instVarNamed: 'sessionId' put: sessionID;
            instVarNamed: 'serverInterface' put: interface;
            yourself
    ] ensure: [ servicePtr free. userPtr free. passPtr free ]
]

{ #category : 'transactions' }
GbsSession >> abort [
    ^ serverInterface apiGciAbort: sessionId
]

{ #category : 'transactions' }
GbsSession >> commit [
    ^ serverInterface apiGciCommit: sessionId
]

{ #category : 'execution' }
GbsSession >> evaluateBlock: aBlock [
    "Compiles the block source to a string and executes it on the server"
    ^ self evaluateString: aBlock sourceNode body sourceCode
]

{ #category : 'execution' }
GbsSession >> evaluateString: aString [
    | resultOop buffer size |
    resultOop := serverInterface apiGciExecute: aString context: 20.
    
    "Handle SmallInteger (Tag 2)"
    (resultOop bitAnd: 7) = 2 ifTrue: [ ^ resultOop bitShift: -3 ].
    
    "Handle Nil"
    resultOop = 20 ifTrue: [ ^ nil ].

    "Fetch String Content"
    buffer := ExternalAddress allocate: 1024.
    [
        size := serverInterface apiGciFetchChars: resultOop into: buffer.
        size > 0 ifTrue: [ ^ (buffer copyFrom: 1 to: size) asString ].
    ] ensure: [ buffer free ].

    ^ resultOop
]

{ #category : 'actions' }
GbsSession >> execute: aString [
    | resultOop buffer size |
    resultOop := serverInterface apiGciExecute: aString context: 20.
    
    "1. Check if it is a SmallInteger (Tag 2)"
    (resultOop bitAnd: 7) = 2 ifTrue: [ ^ resultOop bitShift: -3 ].
    
    "2. Check if it is Boolean/Nil (Special Constants)"
    resultOop = 20 ifTrue: [ ^ nil ].
    resultOop = 268 ifTrue: [ ^ true ].
    resultOop = 12 ifTrue: [ ^ false ].

    "3. Try to fetch as a String"
    buffer := ExternalAddress allocate: 1024.
    [
        size := serverInterface apiGciFetchChars: resultOop into: buffer.
        size > 0 ifTrue: [ ^ (buffer copyFrom: 1 to: size) asString ].
    ] ensure: [ buffer free ].

    ^ resultOop "Return raw Oop if not a simple type"
]

{ #category : 'transactions' }
GbsSession >> logout [
    serverInterface apiGciLogout: sessionId.
    GBSM currentSession == self ifTrue: [ GBSM reset ].
]
