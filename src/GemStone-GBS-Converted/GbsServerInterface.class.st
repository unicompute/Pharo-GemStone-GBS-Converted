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
    uniqueInstance := nil
]

{ #category : 'accessing' }
GbsServerInterface class >> uniqueInstance [ ^ UniqueInstance ifNil: [ UniqueInstance := self new ]
]

{ #category : 'api' }
GbsServerInterface >> apiGciAbort [ ^ self ffiCall: #(void GciAbort())
]

{ #category : 'api - session' }
GbsServerInterface >> apiGciAbort: aSessionId [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(void GciAbort(uint64 aSessionId))
        module: libraryPath
]

{ #category : 'api' }
GbsServerInterface >> apiGciCommit [ ^ self ffiCall: #(int GciCommit())
]

{ #category : 'api - session' }
GbsServerInterface >> apiGciCommit: aSessionId [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(bool GciCommit(uint64 aSessionId))
        module: libraryPath
]

{ #category : 'as yet unclassified' }
GbsServerInterface >> apiGciEncrypt: pass buffer: buf size: size [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(char* GciEncrypt(char* pass, char* buf, uint64 size))
        module: libraryPath
        options: #(+ optNonThreaded)
]

{ #category : 'api - password' }
GbsServerInterface >> apiGciEncrypt: aString into: aBuffer [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(char* GciEncrypt(char* aString, void* aBuffer, int64 1024))
]

{ #category : 'api' }
GbsServerInterface >> apiGciEncrypt: s into: b size: z [ ^ self ffiCall: #(void* GciEncrypt(String s, void* b, void* z))
]

{ #category : 'api' }
GbsServerInterface >> apiGciErr: p [ ^ self ffiCall: #(int GciErr(void* p))
]

{ #category : 'api - execution' }
GbsServerInterface >> apiGciExecute: aString context: aContext [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciExecuteStr(char* aString, int64 aContext))
]

{ #category : 'api' }
GbsServerInterface >> apiGciExecuteStr: s context: c [ ^ self ffiCall: #(void* GciExecuteStr(String s, void* c))
]

{ #category : 'api - fetching' }
GbsServerInterface >> apiGciFetchBytes: anOop into: aBuffer size: bufferSize [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciFetchBytes(int64 anOop, int64 1, void* aBuffer, int64 bufferSize))
]

{ #category : 'api - objects' }
GbsServerInterface >> apiGciFetchChars: anOop into: aBuffer [
    "Fetches characters from a GemStone object into a local buffer"
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciFetchChars(uint64 anOop, int64 1, void* aBuffer, int64 1024))
        module: libraryPath
]

{ #category : 'api' }
GbsServerInterface >> apiGciFetchChars: o startingAt: i into: b size: s [ ^ self ffiCall: #(void* GciFetchChars_(void* o, void* i, void* b, void* s))
]

{ #category : 'api - fetching' }
GbsServerInterface >> apiGciFetchOops: anOop startingAt: startIndex into: aBuffer size: numOops [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciFetchOops(int64 anOop, int64 startIndex, void* aBuffer, int64 numOops))
]

{ #category : 'api' }
GbsServerInterface >> apiGciFetchSize: o [ ^ self ffiCall: #(void* GciFetchSize_(void* o))
]

{ #category : 'api' }
GbsServerInterface >> apiGciInit [ ^ self ffiCall: #(int GciInit())
]

{ #category : 'api' }
GbsServerInterface >> apiGciIsKindOfClass: o isKindOf: c [ ^ self ffiCall: #(int GciIsKindOfClass(void* o, void* c))
]

{ #category : 'api - login' }
GbsServerInterface >> apiGciLogin: gemService user: userId pass: password [
    <primitive: #primitiveNativeCall error: errorCode>
    self logGciCall: 'Login attempt for user: ', userId readString.
    ^ self ffiCall: #(uint64 GciLogin(void* gemService, void* userId, void* password))
        module: libraryPath
        options: #(+ optNonThreaded)
]

{ #category : 'api - login' }
GbsServerInterface >> apiGciLoginEx: user pass: password flags: flags context: context [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(bool GciLoginEx(char* user, char* password, int flags, int64 context))
]

{ #category : 'api' }
GbsServerInterface >> apiGciLoginEx: u password: p flags: f context: c [ ^ self ffiCall: #(int GciLoginEx(void* u, void* p, int f, void* c))
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
GbsServerInterface >> apiGciLogout [ ^ self ffiCall: #(int GciLogout())
]

{ #category : 'api - login' }
GbsServerInterface >> apiGciLogout: sessionId [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(bool GciLogout(int sessionId))
]

{ #category : 'api' }
GbsServerInterface >> apiGciSetNet: st host: h net: n service: s [ ^ self ffiCall: #(void GciSetNet(void* st, void* h, void* n, void* s))
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
    ^ self ffiCall: #(char* GciTsVersion())
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
		self apiGciEncrypt: aPassword into: encPassBuffer.
		session := self apiGciLogin: aService user: aUser pass: encPassBuffer.
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
