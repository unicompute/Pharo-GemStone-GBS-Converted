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

{ #category : 'actions' }
GbsSession >> evaluate: aString [
    | rawOop |
    "1. Execute code on Server"
    rawOop := GbsServerInterface uniqueInstance apiGciExecute: aString context: 20.
    
    "2. Decode the result"
    ^ self fetchObject: rawOop
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

{ #category : 'marshaling' }
GbsSession >> fetchObject: anOop [
    | interface size buffer string arr elemOop tag isString isArray |
    
    "1. Handle SmallIntegers"
    tag := anOop bitAnd: 7.
    tag = 2 ifTrue: [ ^ (anOop bitShift: -3) ].

    "2. Handle Special Constants"
    anOop = 20  ifTrue: [ ^ nil ].
    anOop = 268 ifTrue: [ ^ true ].
    anOop = 12  ifTrue: [ ^ false ].

    interface := GbsServerInterface uniqueInstance.

    "3. CHECK IF STRING (Class Oop: 74753)"
    isString := interface apiGciIsKindOfClass: anOop isKindOf: 74753.
    
    isString ifTrue: [
        size := interface apiGciFetchSize: anOop.
        size = 0 ifTrue: [ ^ '' ].
        
        buffer := ExternalAddress allocate: size + 1.
        [
            interface apiGciFetchChars: anOop startingAt: 1 into: buffer size: size + 1.
            string := String new: size.
            1 to: size do: [ :i | 
                string at: i put: (buffer unsignedByteAt: i) asCharacter 
            ].
        ] ensure: [ buffer free ].
        ^ string
    ].

    "4. CHECK IF ARRAY (Class Oop: 66817)"
    isArray := interface apiGciIsKindOfClass: anOop isKindOf: 66817.
    
    isArray ifTrue: [
        size := interface apiGciFetchSize: anOop.
        size = 0 ifTrue: [ ^ #() ].

        "Allocate buffer for 'size' number of 64-bit Oops (8 bytes each)"
        buffer := ExternalAddress allocate: (size * 8).
        [
            "Fetch the Oops directly into the buffer"
            interface apiGciFetchOops: anOop startingAt: 1 into: buffer size: size.
            
            arr := Array new: size.
            1 to: size do: [ :i |
                "Read the Oop at index i (pointer arithmetic)"
                elemOop := buffer unsignedLongLongAt: ((i - 1) * 8) + 1.
                
                "Recursively decode the element"
                arr at: i put: (self fetchObject: elemOop).
            ].
        ] ensure: [ buffer free ].
        ^ arr
    ].

    "5. Fallback"
    ^ '[Oop: ', anOop printString, ']'
]

{ #category : 'actions' }
GbsSession >> logout [
    GbsServerInterface uniqueInstance apiGciLogout: sessionId
]

{ #category : 'accessing' }
GbsSession >> sessionId [ ^ sessionId
]

{ #category : 'accessing' }
GbsSession >> sessionId: anInteger [ sessionId := anInteger
]
