Class {
	#name : 'GbsSessionTest',
	#superclass : 'TestCase',
	#instVars : [
		'session'
	],
	#category : 'GemStone-Pharo-Tests',
	#package : 'GemStone-Pharo-Tests'
}

{ #category : 'running' }
GbsSessionTest >> setUp [
    super setUp.
    session := GbsSession new.
]

{ #category : 'running' }
GbsSessionTest >> testResultForComplexObjectReturnsProxy [

  | result |
  "1000 is not a special tag, should result in a GbsProxy"
  result := session resultFor: 1000.
  self assert: ( result isKindOf: GbsProxy ).
  self assert: result oop equals: 1000.
  self assert: result session equals: session
]

{ #category : 'running' }
GbsSessionTest >> testResultForPrimitives [
  "Verify Tag mapping per GS64 3.7 Programming Guide"

  self assert: ( session resultFor: 20 ) isNil.
  self assert: ( session resultFor: 28 ).
  self deny: ( session resultFor: 12 ).
  self assert: ( session resultFor: 82 ) equals: 10.
  "$A (65): (65 << 3) + 6 = 526"
  self assert: ( session resultFor: 526 ) equals: $A
]
