Class {
	#name : 'GbsProxy',
	#superclass : 'Object',
	#instVars : [
		'oop',
		'session'
	],
	#category : 'GemStone-GBS-Converted',
	#package : 'GemStone-GBS-Converted'
}

{ #category : 'forwarding' }
GbsProxy >> at: k [ ^ session evaluate: '(Object _objectForOop: ', oop printString, ') at: ', k printString
]

{ #category : 'forwarding' }
GbsProxy >> at: k put: v [ ^ session evaluate: '(Object _objectForOop: ', oop printString, ') at: ', k printString, ' put: ', v printString
]

{ #category : 'private' }
GbsProxy >> convertRemoteDictionary: aProxy [
    | keys size localDict key value |
    size := aProxy size.
    localDict := Dictionary new.
    keys := aProxy keys. "This returns a Proxy to the KeySet"
    
    "Iterate through keys (we assume keys are Strings for instVars)"
    "This is a simplified fetch - for a robust tool we would use GciTraversal"
    "For now, we just fetch the keys as a list"
    
    "Hack: Ask GemStone to dump the dictionary as an Array of Associations"
    "This avoids making 100 round trips"
    
    ^ session evaluate: '((Object _objectForOop: ', aProxy oop printString, ') associations collect: [:a | a key -> a value]) asArray'
]

{ #category : 'interactive evaluation' }
GbsProxy >> doItContext [
    "Required by Pharo Inspector to execute code against this object"
    ^ nil
]

{ #category : 'interactive evaluation' }
GbsProxy >> doItReceiver [
    "When code is executed in the inspector, it runs on the remote object"
    ^ self
]

{ #category : 'forwarding' }
GbsProxy >> doesNotUnderstand: m [
    | query |
    m arguments isEmpty ifFalse: [ ^ super doesNotUnderstand: m ].
    query := '(Object _objectForOop: ', oop printString, ') ', m selector.
    ^ session evaluate: query
]

{ #category : 'interactive evaluation' }
GbsProxy >> evaluate: aString [
    "Execute the string on the REMOTE object (self)"
    | query |
    query := '(Object _objectForOop: ', oop printString, ') ', aString.
    ^ session evaluate: query
]

{ #category : 'inspection' }
GbsProxy >> fetchRemoteInstVars [
    | query result |
    "Query: Return a Dictionary where keys are names and values are OOPs (not strings)"
    query := '| obj dict | 
              obj := Object _objectForOop: ', oop printString, '.
              dict := Dictionary new. 
              obj class allInstVarNames do: [:n | dict at: n put: (obj instVarNamed: n)].
              dict'.
    
    "This returns a Proxy to a Dictionary of OOPs"
    result := session evaluate: query.
    
    "Now we must download that dictionary to Pharo as a local dictionary of Proxies"
    ^ self convertRemoteDictionary: result
]

{ #category : 'inspection' }
GbsProxy >> inspectionRemoteInstVars: aBuilder [
    <inspectorPresentationOrder: 0 title: 'GemStone InstVars'>
    
    ^ aBuilder newTable
        addColumn: (SpStringTableColumn title: 'Variable' evaluated: #key);
        addColumn: (SpStringTableColumn title: 'Value' evaluated: #value);
        items: [ 
            "Ask GemStone for associations directly"
            (session evaluate: '
                | obj | 
                obj := Object _objectForOop: ', oop printString, '.
                obj class allInstVarNames collect: [:n | n -> (obj instVarNamed: n)]
            ') asOrderedCollection
        ];
        yourself
]

{ #category : 'accessing' }
GbsProxy >> inspectorString [
    ^ self printString
]

{ #category : 'accessing' }
GbsProxy >> inspectorTitle [
    ^ [ self printString ] on: Error do: [ 'GbsProxy (Disconnected)' ]
]

{ #category : 'forwarding' }
GbsProxy >> keys [ ^ session evaluate: '(Object _objectForOop: ', oop printString, ') keys'
]

{ #category : 'initialization' }
GbsProxy >> oop: o session: s [ oop := o. session := s.
]

{ #category : 'printing' }
GbsProxy >> printOn: s [ | remote | [ remote := session evaluate: '(Object _objectForOop: ', oop printString, ') printString'. s nextPutAll: remote ] on: Error do: [ s nextPutAll: 'GbsProxy(', oop printString, ')' ]
]

{ #category : 'forwarding' }
GbsProxy >> size [ ^ session evaluate: '(Object _objectForOop: ', oop printString, ') size'
]
