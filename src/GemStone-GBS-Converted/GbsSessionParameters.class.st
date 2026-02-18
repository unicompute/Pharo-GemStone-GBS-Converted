Class {
	#name : 'GbsSessionParameters',
	#superclass : 'Object',
	#instVars : [
		'gemStoneName',
		'username',
		'password'
	],
	#classVars : [
		'CurrentSession'
	],
	#category : 'GemStone-GBS-Converted',
	#package : 'GemStone-GBS-Converted'
}

{ #category : 'accessing' }
GbsSessionParameters class >> currentSession [ ^ CurrentSession
]

{ #category : 'accessing' }
GbsSessionParameters >> gemService [ ^ gemService
]

{ #category : 'accessing' }
GbsSessionParameters >> gemService: aString [ gemService := aString
]

{ #category : 'accessing' }
GbsSessionParameters >> gemStoneName [ ^ gemStoneName
]

{ #category : 'accessing' }
GbsSessionParameters >> gemStoneName: n [ gemStoneName := n
]

{ #category : 'actions' }
GbsSessionParameters >> login [

  | interface outBuf stonePtr userPtr servicePtr emptyPtr result |
  CurrentSession := nil.

  interface := GbsServerInterface uniqueInstance.
  interface apiGciInit.

  outBuf := ExternalAddress allocate: 1024.
  stonePtr := ExternalAddress allocate: gemStoneName size + 1.
  userPtr := ExternalAddress allocate: username size + 1.
  servicePtr := ExternalAddress allocate: 14.
  emptyPtr := ExternalAddress allocate: 1.

  [
    1 to: gemStoneName size do: [ :i | stonePtr byteAt: i put: ( gemStoneName at: i ) asInteger ].
    stonePtr byteAt: gemStoneName size + 1 put: 0.

    1 to: username size do: [ :i | userPtr byteAt: i put: ( username at: i ) asInteger ].
    userPtr byteAt: username size + 1 put: 0.

    #( $g $e $m $n $e $t $o $b $j $e $c $t ) withIndexDo: [ :c :i |
      servicePtr byteAt: i put: c asInteger ].
    servicePtr byteAt: 13 put: 0.
    emptyPtr byteAt: 1 put: 0.

    interface apiGciEncrypt: password into: outBuf size: 1024.
    interface
      apiGciSetNet: stonePtr
      host: emptyPtr
      net: emptyPtr
      service: servicePtr.

    result := interface
                apiGciLoginEx: userPtr
                password: outBuf
                flags: 3
                context: 0.

    result = 1 ifFalse: [
        interface checkError.
        self error: 'Login Failed'
        ]
    ] ensure: [
      outBuf free.
      stonePtr free.
      userPtr free.
      servicePtr free.
      emptyPtr free
      ].

  CurrentSession := GbsSession new
                      sessionOop: 1;
                      parameters: self;
                      yourself.
  ^ CurrentSession
]

{ #category : 'accessing' }
GbsSessionParameters >> password: n [ password := n
]

{ #category : 'accessing' }
GbsSessionParameters >> username: n [ username := n
]
