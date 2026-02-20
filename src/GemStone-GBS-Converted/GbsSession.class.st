Class {
	#name : 'GbsSession',
	#superclass : 'Object',
	#instVars : [
		'sessionOop',
		'parameters'
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
    "Discards uncommitted changes and syncs with the latest GemStone state."
    GbsServerInterface uniqueInstance apiGciAbort: self sessionOop.
    ^ true.
]

{ #category : 'evaluating' }
GbsSession >> basicEvaluate: aString [
    | resultOop |
    "Execute and get the raw OOP" 
    resultOop := GbsServerInterface uniqueInstance 
        apiGciExecuteStr: aString 
        context: sessionOop. 
    
    "Crucial: Convert the raw resultOop into a Pharo object or Proxy"
    ^ GbsServerInterface uniqueInstance resultFor: resultOop.
]

{ #category : 'transactions' }
GbsSession >> commit [
    "Flushes local object changes to the GemStone database."
    ^ GbsServerInterface uniqueInstance apiGciCommit: self sessionOop.
]

{ #category : 'execution' }
GbsSession >> evaluate: s [ | i r | i := GbsServerInterface uniqueInstance. r := i apiGciExecuteStr: s context: 20. i checkError. ^ self fetchObject: r asInteger
]

{ #category : 'evaluating' }
GbsSession >> evaluateAndFetchString: aString [
    | resultOop |
    "Execute on server"
    resultOop := GbsServerInterface uniqueInstance 
        apiGciExecuteStr: aString 
        context: sessionOop.
        
    "Fetch the actual characters using the fixed fetcher"
    ^ GbsServerInterface uniqueInstance fetchString: resultOop.
]

{ #category : 'execution' }
GbsSession >> evaluateBlock: aBlock [
    "Compiles the block source to a string and executes it on the server"
    ^ self evaluateString: aBlock sourceNode body sourceCode
]

{ #category : 'evaluating' }
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

{ #category : 'execution' }
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
    | i szPtr sz buf str classOop |
    "1. Literal / Immediate Checks"
    anOop = 20 ifTrue: [ ^ nil ]. 
    anOop = 268 ifTrue: [ ^ true ]. 
    anOop = 12 ifTrue: [ ^ false ]. 
    (anOop bitAnd: 7) = 2 ifTrue: [ ^ (anOop bitShift: -3) ]. "SmallInteger"

    i := GbsServerInterface uniqueInstance.

    "2. String Check (Class 74753)"
    (i apiGciIsKindOfClass: anOop isKindOf: 74753) = 1 ifTrue: [
        szPtr := i apiGciFetchSize: anOop.
        sz := szPtr asInteger. (sz <= 0) ifTrue: [ ^ '' ].
        buf := ExternalAddress allocate: sz + 1.
        [ i apiGciFetchChars: anOop startingAt: 1 into: buf size: sz + 1. 
          str := String new: sz. 
          1 to: sz do: [ :x | str at: x put: (buf unsignedByteAt: x) asCharacter ]. 
        ] ensure: [ buf free ].
        ^ str 
    ].

    "3. DateTime Marshaling"
    "We ask GemStone for the ISO string and convert it to a Pharo DateAndTime"
    (i apiGciIsKindOfClass: anOop isKindOf: 74241) = 1 ifTrue: [
        str := self evaluate: '(Object _objectForOop: ', anOop printString, ') asString'.
        ^ DateAndTime readFrom: str readStream.
    ].

    "4. Array Marshaling (Recursive)"
    "If it is a small Array, we convert it to a Pharo Array of objects/proxies"
    (i apiGciIsKindOfClass: anOop isKindOf: 66817) = 1 ifTrue: [
        szPtr := i apiGciFetchSize: anOop.
        sz := szPtr asInteger.
        "Only auto-marshal small arrays (< 100 elements) to avoid freezing Pharo"
        (sz > 0 and: [ sz < 100 ]) ifTrue: [ | localArray |
            localArray := Array new: sz.
            1 to: sz do: [ :idx | | elementOop |
                "We use a specialized GCI call to get the OOP at index"
                "For now, we evaluate a quick script for simplicity"
                elementOop := self evaluate: '(Object _objectForOop: ', anOop printString, ') at: ', idx printString.
                localArray at: idx put: elementOop.
            ].
            ^ localArray
        ].
    ].

    "Default: Return a Proxy"
    ^ GbsProxy new oop: anOop session: self
]

{ #category : 'accessing' }
GbsSession >> fetchRemoteClassNamesIn: dictionaryName [

  | script rawString |
  script := '
        | dict stream |
        stream := WriteStream on: String new.
        dict := System myUserProfile symbolList objectNamed: #' , dictionaryName , '.
        dict ifNotNil: [
            dict keysAndValuesDo: [:key :value |
                value isBehavior ifTrue: [ 
                    stream nextPutAll: key asString; nextPut: $, 
                ]
            ]
        ].
        stream contents
    '.

  "1. Evaluates the script, returning a local String by value"
  rawString := self evaluate: script.

  "2. Splitting it on the client creates a local Array, which IS a Collection"
  ^ rawString substrings: ','
]

{ #category : 'browser backend' }
GbsSession >> fetchRemoteDictionaries [
    "Queries GemStone for all dictionary names in the user's symbol list, returned as a fast comma-separated string."
    | script rawString |
    
    script := '| strm |
    strm := WriteStream on: String new.
    System myUserProfile symbolList 
        do: [:dict | strm nextPutAll: dict name asString] 
        separatedBy: [strm nextPutAll: '',''].
    strm contents'.
        
    rawString := self evaluate: script.
    
    "Unbox if it came back as a Proxy"
    (rawString class name = #GbsProxy) ifTrue: [ rawString := rawString asLocalString ].
    
    "Split the comma-separated string into a native Pharo Array"
    ^ rawString substrings: ','.
]

{ #category : 'evaluating' }
GbsSession >> fetchTranscriptLogs [
    ^ GbsServerInterface uniqueInstance 
        executeAndPrint: 'Transcript fetchAndClear' 
        inSession: sessionOop.
]

{ #category : 'testing' }
GbsSession >> isConnected [
    "In GBS, if we have a sessionOop, we are connected"
    ^ sessionOop isNotNil and: [ sessionOop asInteger ~= 0 ]
]

{ #category : 'actions' }
GbsSession >> logout [ sessionOop ifNotNil: [ GbsServerInterface uniqueInstance apiGciLogout. sessionOop := nil ]
]

{ #category : 'accessing' }
GbsSession >> parameters: p [ parameters := p. GbsSessionParameters classPool at: #CurrentSession put: self
]

{ #category : 'evaluating' }
GbsSession >> resultFor: anOop [
  "Identify special GemStone OOP tags (GS64 3.7 Guide, Chapter 5)"

  anOop = 20 ifTrue: [ ^ nil ].
  anOop = 28 ifTrue: [ ^ true ].
  anOop = 12 ifTrue: [ ^ false ].

  "Check if it's a SmallInteger (Tag 2)"
  ( anOop bitAnd: 7 ) = 2 ifTrue: [ ^ anOop bitShift: -3 ].

  "Check if it's a Character (Tag 6)"
  "Check if it's a Character (Tag 6)"
  ( anOop bitAnd: 7 ) = 6 ifTrue: [ ^ Character codePoint: ( anOop bitShift: -3 ) ].

  "If it's not a primitive, it's a complex object. Return a Proxy."
  ^ GbsProxy oop: anOop session: self
]

{ #category : 'accessing' }
GbsSession >> sessionId [ ^ sessionId
]

{ #category : 'accessing' }
GbsSession >> sessionId: anInteger [ sessionId := anInteger
]

{ #category : 'accessing' }
GbsSession >> sessionOop [
    ^ sessionOop
]

{ #category : 'accessing' }
GbsSession >> sessionOop: anInteger [
    sessionOop := anInteger
]

{ #category : 'signalling' }
GbsSession >> signalError: aGciError [
	"Translates a GemStone C-level error into a Pharo exception"
	| errorMessage |
	
	errorMessage := aGciError message. 
	
	^ GbsError signal: errorMessage
]
