Class {
	#name : 'GbsSessionParameters',
	#superclass : 'GbxSessionSpecification',
	#instVars : [
		'gemStoneName',
		'hostUsername',
		'hostPassword',
		'gemService',
		'rememberPassword',
		'rememberHostPassword'
	],
	#category : 'GemStone-GBS-Converted',
	#package : 'GemStone-GBS-Converted'
}

{ #category : 'accessing' }
GbsSessionParameters >> gemService: aString [ gemService := aString
]

{ #category : 'accessing' }
GbsSessionParameters >> gemStoneName: aString [ gemStoneName := aString
]

{ #category : 'operations' }
GbsSessionParameters >> login [
    "Attempts to login and returns a configured GbsSession"
    | interface servicePtr userPtr passPtr sessionID newSession |
    interface := GbsServerInterface uniqueInstance.
    interface apiGciInit.
    
    "Resolve Service Name (Use gemService if set, otherwise default to Stone name)"
    servicePtr := ExternalAddress fromString: (gemService ifNil: [ gemStoneName ]).
    userPtr := ExternalAddress fromString: username.
    passPtr := ExternalAddress fromString: password.
    
    [
        sessionID := interface apiGciLogin: servicePtr user: userPtr pass: passPtr.
        
        sessionID = 0 ifTrue: [ 
            Transcript show: 'Login Failed.'; cr. 
            ^ nil 
        ].
        
        newSession := GbsSession new.
        newSession instVarNamed: 'sessionId' put: sessionID.
        newSession instVarNamed: 'serverInterface' put: interface.
        
        "Register as current session per GBS standard"
        GBSM currentSession: newSession.
        
        ^ newSession
        
    ] ensure: [ servicePtr free. userPtr free. passPtr free ]
]

{ #category : 'accessing' }
GbsSessionParameters >> password: aString [ password := aString
]

{ #category : 'accessing' }
GbsSessionParameters >> username: aString [ username := aString
]
