Extension { #name : 'String' }

{ #category : '*GemStone-GBS-Converted' }
String >> asGemStoneUTF8Bytes [
    "Converts the string into a UTF-8 encoded ByteArray for safe transport to GemStone.
     This safely handles both standard ASCII and multibyte Unicode characters (like emojis)."
    
    ^ self utf8Encoded
]

{ #category : '*GemStone-GBS-Converted' }
String class >> fromGemStoneUTF8Bytes: aByteArray [
    "Decodes a UTF-8 ByteArray coming from GemStone into a Pharo String.
     Automatically promotes to a WideString if multibyte characters are present."
    
    ^ aByteArray utf8Decoded
]
