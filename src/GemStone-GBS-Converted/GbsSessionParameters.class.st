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
GbsSessionParameters >> gemService [ ^ gemService
]

{ #category : 'accessing' }
GbsSessionParameters >> gemService: aString [ gemService := aString
]

{ #category : 'accessing' }
GbsSessionParameters >> gemStoneName [ ^ gemStoneName
]

{ #category : 'accessing' }
GbsSessionParameters >> gemStoneName: aString [ gemStoneName := aString
]

{ #category : 'accessing' }
GbsSessionParameters >> password: aString [ password := aString
]

{ #category : 'accessing' }
GbsSessionParameters >> username: aString [ username := aString
]
