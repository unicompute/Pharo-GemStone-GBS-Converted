Class {
	#name : 'GbsServerInterface',
	#superclass : 'FFILibrary',
	#instVars : [
		'libraryPath'
	],
	#category : 'GemStone-GBS-Converted',
	#package : 'GemStone-GBS-Converted'
}

{ #category : 'initialization' }
GbsServerInterface class >> reset [
    "Resets the singleton instance to nil"
    uniqueInstance := nil
]

{ #category : 'api - session' }
GbsServerInterface >> apiGciAbort: aSessionId [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(void GciAbort(uint64 aSessionId))
        module: libraryPath
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

{ #category : 'api - errors' }
GbsServerInterface >> apiGciErr: errorBuffer [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(bool GciErr(void* errorBuffer))
        module: '/Users/tariq/GemStone64Bit3.7.4.3-arm64.Darwin/lib/libgcirpc-3.7.4.3-64.dylib'
        options: #(+ optNonThreaded)
]

{ #category : 'api - execution' }
GbsServerInterface >> apiGciExecute: aString context: aContext [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciExecuteStr(char* aString, int64 aContext))
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

{ #category : 'api - fetching' }
GbsServerInterface >> apiGciFetchChars: anOop startingAt: startIndex into: aBuffer size: bufferSize [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciFetchChars_(int64 anOop, int64 startIndex, void* aBuffer, int64 bufferSize))
]

{ #category : 'api - fetching' }
GbsServerInterface >> apiGciFetchOops: anOop startingAt: startIndex into: aBuffer size: numOops [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciFetchOops(int64 anOop, int64 startIndex, void* aBuffer, int64 numOops))
]

{ #category : 'api - fetching' }
GbsServerInterface >> apiGciFetchSize: anOop [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(int64 GciFetchSize_(int64 anOop))
]

{ #category : 'api - init' }
GbsServerInterface >> apiGciInit [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(void GciInit(void))
        module: '/Users/tariq/GemStone64Bit3.7.4.3-arm64.Darwin/lib/libgcirpc-3.7.4.3-64.dylib'
        options: #(+ optNonThreaded)
]

{ #category : 'api - structural' }
GbsServerInterface >> apiGciIsKindOfClass: anOop isKindOf: aClassOop [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(bool GciIsKindOfClass(int64 anOop, int64 aClassOop))
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

{ #category : 'api - login' }
GbsServerInterface >> apiGciLogout: sessionId [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(bool GciLogout(int sessionId))
]

{ #category : 'api - connection' }
GbsServerInterface >> apiGciSetNet: stoneName host: hostName net: netName service: serviceName [
    <primitive: #primitiveNativeCall error: errorCode>
    ^ self ffiCall: #(void GciSetNet(char* stoneName, char* hostName, char* netName, char* serviceName))
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
GbsServerInterface >> libraryPath [
    ^ libraryPath
]

{ #category : 'accessing' }
GbsServerInterface >> libraryPath: aString [
    libraryPath := aString
]

{ #category : 'debugging' }
GbsServerInterface >> logGciCall: aString [ 
    Transcript show: '[GCI] ', aString; cr
]
