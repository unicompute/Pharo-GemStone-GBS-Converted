Extension { #name : 'ByteString' }

{ #category : '*GemStone-GBS-Converted' }
ByteString >> asExternalString [
    "Bridge VisualWorks code to Pharo FFI"
    ^ ExternalAddress fromString: self
]
