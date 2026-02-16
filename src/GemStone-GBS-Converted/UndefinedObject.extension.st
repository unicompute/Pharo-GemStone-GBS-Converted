Extension { #name : 'UndefinedObject' }

{ #category : '*GemStone-GBS-Converted' }
UndefinedObject >> bridgeToGbsSession: rawSessionId interface: anInterface [
    | newSession |
    
    "1. Create the high-level GBS Session object"
    newSession := GbsSession new.
    
    "2. Inject the working FFI session ID"
    "Based on standard GBS patterns, this is usually stored in an instVar named 'sessionId' or 'handle'"
    (newSession class includesInstVarNamed: 'sessionId') 
        ifTrue: [ newSession instVarNamed: 'sessionId' put: rawSessionId ]
        ifFalse: [ newSession instVarNamed: 'handle' put: rawSessionId ].
        
    "3. Attach the Interface"
    newSession instVarNamed: 'serverInterface' put: anInterface.
    
    Transcript show: 'Mapped to GbsSession instance: ', newSession printString; cr.
    
    "4. Test High-Level Execution"
    Transcript show: 'Executing via GbsSession: '.
    Transcript show: (newSession execute: '1 + 1') printString.
    
    ^ newSession
]
