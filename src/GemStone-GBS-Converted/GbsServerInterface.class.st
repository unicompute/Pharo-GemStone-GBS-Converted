Class {
	#name : 'GbsServerInterface',
	#superclass : 'Object',
	#instVars : [
		'libraryPath'
	],
	#classInstVars : [
		'UniqueInstance'
	],
	#category : 'GemStone-GBS-Converted',
	#package : 'GemStone-GBS-Converted'
}

{ #category : 'as yet unclassified' }
GbsServerInterface class >> initialize [ UniqueInstance := nil
]

{ #category : 'initialization' }
GbsServerInterface class >> reset [
    "Resets the singleton instance to nil"
    UniqueInstance := nil
]

{ #category : 'accessing' }
GbsServerInterface class >> uniqueInstance [ ^ UniqueInstance ifNil: [ UniqueInstance := self new ]
]

{ #category : 'api' }
GbsServerInterface >> apiGciAbort [ ^ self ffiCall: #(void GciAbort()) module: libraryPath
]
{ #category : 'api - session' }
GbsServerInterface >> apiGciAbort: aSessionId [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(void GciAbort(uint64 aSessionId)) module: libraryPath
        module: libraryPath
]

{ #category : 'api' }
GbsServerInterface >> apiGciCommit [ ^ self ffiCall: #(int GciCommit()) module: libraryPath
]
{ #category : 'api - session' }
GbsServerInterface >> apiGciCommit: aSessionId [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(bool GciCommit(uint64 aSessionId)) module: libraryPath
        module: libraryPath
]

{ #category : 'as yet unclassified' }
GbsServerInterface >> apiGciEncrypt: pass buffer: buf size: size [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(char* GciEncrypt(char* pass, char* buf, uint64 size)) module: libraryPath
        module: libraryPath
        options: #(+ optNonThreaded)
]

{ #category : 'api - password' }
GbsServerInterface >> apiGciEncrypt: aString into: aBuffer [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(char* GciEncrypt(char* aString, void* aBuffer, int64 1024)) module: libraryPath
]
{ #category : 'api' }
GbsServerInterface >> apiGciEncrypt: s into: b size: z [ ^ self ffiCall: #(void* GciEncrypt(String s, void* b, void* z)) module: libraryPath
]
{ #category : 'api' }
GbsServerInterface >> apiGciErr: p [ ^ self ffiCall: #(int GciErr(void* p)) module: libraryPath
]
{ #category : 'api - execution' }
GbsServerInterface >> apiGciExecute: aString context: aContext [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciExecuteStr(char* aString, int64 aContext)) module: libraryPath
]
{ #category : 'api' }
GbsServerInterface >> apiGciExecuteStr: s context: c [ ^ self ffiCall: #(void* GciExecuteStr(String s, void* c)) module: libraryPath
]
{ #category : 'api - fetching' }
GbsServerInterface >> apiGciFetchBytes: anOop into: aBuffer size: bufferSize [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciFetchBytes(int64 anOop, int64 1, void* aBuffer, int64 bufferSize)) module: libraryPath
]
{ #category : 'api - objects' }
GbsServerInterface >> apiGciFetchChars: anOop into: aBuffer [
    "Fetches characters from a GemStone object into a local buffer"
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciFetchChars(uint64 anOop, int64 1, void* aBuffer, int64 1024)) module: libraryPath
        module: libraryPath
]

{ #category : 'api' }
GbsServerInterface >> apiGciFetchChars: o startingAt: i into: b size: s [ ^ self ffiCall: #(void* GciFetchChars_(void* o, void* i, void* b, void* s)) module: libraryPath
]
{ #category : 'api - fetching' }
GbsServerInterface >> apiGciFetchOops: anOop startingAt: startIndex into: aBuffer size: numOops [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciFetchOops(int64 anOop, int64 startIndex, void* aBuffer, int64 numOops)) module: libraryPath
]
{ #category : 'api' }
GbsServerInterface >> apiGciFetchSize: o [ ^ self ffiCall: #(void* GciFetchSize_(void* o)) module: libraryPath
]
{ #category : 'ffi' }
GbsServerInterface >> apiGciGetClass: anOop [
    "Fetch the Class OOP of a remote object"
    ^ self ffiCall: #( uint64 GciFetchClass ( uint64 anOop ) )  module: libraryPath
           module: libraryPath
]

{ #category : 'api' }
GbsServerInterface >> apiGciInit [ ^ self ffiCall: #(int GciInit()) module: libraryPath
]
{ #category : 'api' }
GbsServerInterface >> apiGciIsKindOfClass: o isKindOf: c [ ^ self ffiCall: #(int GciIsKindOfClass(void* o, void* c)) module: libraryPath
]
{ #category : 'ffi' }
GbsServerInterface >> apiGciIsString: anOop [
    ^ self ffiCall: #( bool GciIsString ( uint64 anOop ) )  module: libraryPath
           module: libraryPath
]

{ #category : 'api - login' }
GbsServerInterface >> apiGciLogin: gemService user: userId pass: password [
    <primitive: #primitiveNativeCall error: errorCode>
    self logGciCall: 'Login attempt for user: ', userId readString.
    ^ self ffiCall: #(uint64 GciLogin(void* gemService, void* userId, void* password)) module: libraryPath
        module: libraryPath
        options: #(+ optNonThreaded)
]

{ #category : 'api - login' }
GbsServerInterface >> apiGciLoginEx: user pass: password flags: flags context: context [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(bool GciLoginEx(char* user, char* password, int flags, int64 context)) module: libraryPath
]
{ #category : 'api' }
GbsServerInterface >> apiGciLoginEx: u password: p flags: f context: c [ ^ self ffiCall: #(int GciLoginEx(void* u, void* p, int f, void* c)) module: libraryPath
]
{ #category : 'api - login' }
GbsServerInterface >> apiGciLoginEx: gemService user: userId pass: password [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(uint64 GciLoginEx(
            void* gemService, 
            void* userId, 
            void* password,
            void* 0,        "hostUserId"
            void* 0,        "hostPassword"
            int 0,          "loginFlags"
            int 0           "haltOnConnect"))
        module: libraryPath
        options: #(+ optNonThreaded)
]

{ #category : 'api' }
GbsServerInterface >> apiGciLogout [ ^ self ffiCall: #(int GciLogout()) module: libraryPath
]
{ #category : 'api - login' }
GbsServerInterface >> apiGciLogout: sessionId [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(bool GciLogout(int sessionId)) module: libraryPath
]
{ #category : 'api' }
GbsServerInterface >> apiGciSetNet: st host: h net: n service: s [ ^ self ffiCall: #(void GciSetNet(void* st, void* h, void* n, void* s)) module: libraryPath
]
{ #category : 'api - login' }
GbsServerInterface >> apiGciTsLogin: gemService user: userId pass: password encrypted: isEncrypted remote: isRemote [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(uint64 GciTsLogin(
            char* gemService, 
            char* userId, 
            char* password, 
            int isEncrypted, 
            int isRemote,
            int 0, void* 0, int 0, int 0))
        module: libraryPath
]

{ #category : 'api - helpers' }
GbsServerInterface >> apiGciTsVersion [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(char* GciTsVersion()) module: libraryPath
        module: libraryPath
]

{ #category : 'error handling' }
GbsServerInterface >> checkError [
    | errInfo result exOop |
    errInfo := GciErrSType new.
    result := self apiGciErr: errInfo getHandle.
    result = 1 ifTrue: [ 
        exOop := errInfo exceptionOop.
        GbsError new 
            messageText: ('GemStone Error: ', errInfo message);
            gemStoneExceptionProxy: (GbsProxy new oop: exOop session: GbsSessionParameters currentSession);
            signal
    ].
]

{ #category : 'as yet unclassified' }
GbsServerInterface >> checkGciError [
    | buffer errNum |
    buffer := ExternalAddress allocate: 2168.
    [
        (self apiGciErr: buffer) ifTrue: [
            errNum := buffer signedLongAt: 5. 
            Transcript cr; show: '>>> GCI ERROR ', errNum printString, ': ', (buffer + 112) readString.
        ]
    ] ensure: [ buffer free ]
]

{ #category : 'api - errors' }
GbsServerInterface >> checkGciError: anInterface [

  | buffer errNum |
  buffer := ExternalAddress allocate: 2168.
  [
    ( anInterface apiGciErr: buffer ) ifTrue: [
        errNum := buffer signedLongAt: 5. "Pharo offset for 32-bit error number"
        Transcript
          show: '>>> ERROR ' , errNum printString , ': ';
          show: ( buffer + 112 ) readString
        ]
    ] ensure: [ buffer free ]
]

{ #category : 'execution' }
GbsServerInterface >> execute: aString inSession: aSessionId [
    "Route the workspace execution to the underlying GemStone FFI call"
    
    ^ self apiGciExecuteStr: aString context: aSessionId.
]

{ #category : 'execution' }
GbsServerInterface >> executeAndPrint: aString inSession: aSessionId [
    | stringOop |
    "Execute and expect a String OOP back"
    stringOop := self apiGciExecuteStr: aString context: aSessionId.
    ^ self fetchString: stringOop.
]

{ #category : 'fetching' }
GbsServerInterface >> fetchString: anOop [
    | sizeResult size buffer currentSessionOop |
    
    sizeResult := self apiGciFetchSize: anOop.
    size := (sizeResult isKindOf: ExternalAddress) ifTrue: [ sizeResult asInteger ] ifFalse: [ sizeResult ].
    
    (size <= 0) ifTrue: [ ^ '' ].
    
    currentSessionOop := GbsSessionParameters currentSession sessionOop.
    
    buffer := ByteArray new: size.
    self apiGciFetchChars: anOop 
         context: currentSessionOop 
         into: buffer 
         size: size.
         
    ^ buffer asString.
]

{ #category : 'ffi-binding' }
GbsServerInterface >> ffiLibraryName [ ^ libraryPath
]

{ #category : 'GemStone-GBS-Converted' }
GbsServerInterface >> gciExecuteStr: aSource context: aContext [
	"Bridge converted VW code to our working ARM64 FFI"
	^ self apiGciExecute: aSource context: aContext
]

{ #category : 'GemStone-GBS-Converted' }
GbsServerInterface >> gciLogin: aService user: aUser password: aPassword [
	"The converted code likely calls this. We handle the encryption automatically here."
	| encBuffer session |
	encBuffer := ExternalAddress allocate: 1024.
	[
		self apiGciInit. "Ensure library is initialized"
		self apiGciEncrypt: aPassword into: encBuffer.
		session := self apiGciLogin: aService user: aUser pass: encBuffer.
	] ensure: [ encBuffer free ].
	^ session
]

{ #category : 'accessing' }
GbsServerInterface >> libraryName [ 
    ^ libraryPath
]

{ #category : 'accessing' }
GbsServerInterface >> libraryName: aString [ 
    libraryPath := aString
]

{ #category : 'accessing' }
GbsServerInterface >> libraryPath [ ^ libraryPath
]

{ #category : 'accessing' }
GbsServerInterface >> libraryPath: s [ libraryPath := s
]

{ #category : 'debugging' }
GbsServerInterface >> logGciCall: aString [ 
    Transcript show: '[GCI] ', aString; cr
]

{ #category : 'conversion' }
GbsServerInterface >> resultFor: anOop [
    | classOop |
    (anOop isNil or: [ anOop asInteger = 0 ]) ifTrue: [ ^ nil ].
    
    "Check for SmallInteger (bit 0 is 1)"
    (anOop asInteger bitAnd: 1) = 1 ifTrue: [ ^ anOop asInteger >> 1 ].
    
    "Check for common literals like nil, true, false (Special OOPs)"
    anOop asInteger = 20 ifTrue: [ ^ nil ].
    anOop asInteger = 268 ifTrue: [ ^ true ].
    anOop asInteger = 140 ifTrue: [ ^ false ].

    "Get the Class of the remote object"
    classOop := self apiGciGetClass: anOop.
    
    "GemStone String classes: String=74, Symbol=110, DoubleByteString=146"
    (#(74 110 146) includes: classOop asInteger) ifTrue: [ ^ self fetchString: anOop ].
    
    "Otherwise, return the Proxy"
    ^ GbsProxy for: anOop session: GbsSessionParameters currentSession.
]
