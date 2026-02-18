Class {
	#name : 'GbsLauncher',
	#superclass : 'SpPresenter',
	#instVars : [
		'inputStone',
		'inputUser',
		'inputPass',
		'inputLibPath',
		'btnLogin',
		'btnLogout',
		'btnWorkspace',
		'btnBrowser',
		'btnTranscript',
		'statusLabel'
	],
	#category : 'GemStone-GBS-Tools',
	#package : 'GemStone-GBS-Tools'
}

{ #category : 'layout' }
GbsLauncher >> defaultLayout [

  ^ SpBoxLayout newVertical
      spacing: 5;
      add: ( SpGridLayout new
            add: 'Stone:' atPoint: 1 @ 1;
            add: inputStone atPoint: 2 @ 1;
            add: 'User:' atPoint: 1 @ 2;
            add: inputUser atPoint: 2 @ 2;
            add: 'Pass:' atPoint: 1 @ 3;
            add: inputPass atPoint: 2 @ 3;
            add: 'Lib:' atPoint: 1 @ 4;
            add: inputLibPath atPoint: 2 @ 4 span: 3 @ 1;
            yourself )
      height: 130;
      add: ( SpBoxLayout newHorizontal
            add: btnLogin;
            add: btnLogout;
            yourself )
      height: 30;
      add: ( SpBoxLayout newVertical
            add: 'Tools' asPresenter;
            add: btnWorkspace;
            add: btnBrowser;
            add: btnTranscript;
            yourself );
      add: statusLabel;
      yourself
]

{ #category : 'actions' }
GbsLauncher >> doLogin [
    | session |
    statusLabel label: 'Status: Connecting...'.
    
    [
        "1. Set Library"
        GbsServerInterface uniqueInstance libraryPath: inputLibPath text.
        
        "2. Attempt Login"
        session := GbsSessionParameters new
            gemStoneName: inputStone text;
            username: inputUser text;
            password: inputPass text;
            login.
            
        "3. UI Update on Success"
        statusLabel label: 'Status: Connected to ', inputStone text.
        btnLogin disable. 
        inputStone disable. inputUser disable. inputPass disable. inputLibPath disable.
        btnLogout enable.
        btnWorkspace enable. btnBrowser enable. btnTranscript enable.
        
        self inform: 'Connected Successfully!'.
        
    ] on: Error do: [ :ex | 
        statusLabel label: 'Status: Error - ', ex messageText.
        self inform: 'Connection Failed: ', ex messageText.
    ].
]

{ #category : 'actions' }
GbsLauncher >> doLogout [
    [
        GbsSessionParameters currentSession ifNotNil: [ :s | s logout ].
        
        "UI Reset"
        statusLabel label: 'Status: Disconnected'.
        btnLogin enable.
        inputStone enable. inputUser enable. inputPass enable. inputLibPath enable.
        btnLogout disable.
        btnWorkspace disable. btnBrowser disable. btnTranscript disable.
        
    ] on: Error do: [ :ex | self inform: 'Error logging out: ', ex messageText ].
]

{ #category : 'initialization' }
GbsLauncher >> initializePresenters [
    "1. Connection Inputs"
    inputStone := self newTextInput text: 'gs64stone'; placeholder: 'Stone Name'.
    inputUser := self newTextInput text: 'DataCurator'; placeholder: 'Username'.
    inputPass := self newTextInput text: 'swordfish'; placeholder: 'Password'; bePassword.
    
    "Default Library Path (Adjust if needed)"
    inputLibPath := self newTextInput 
        text: '/Users/tariq/GemStone64Bit3.7.4.3-arm64.Darwin/lib/libgcirpc-3.7.4.3-64.dylib';
        placeholder: 'Path to libgcirpc.dylib'.

    "2. Action Buttons"
    btnLogin := self newButton label: 'Login'; icon: (self iconNamed: #smallOk).
    btnLogout := self newButton label: 'Logout'; icon: (self iconNamed: #smallCancel); disable.
    
    "3. Tool Buttons (Initially Disabled)"
    btnWorkspace := self newButton label: 'Workspace'; icon: (self iconNamed: #glamorousEdit); disable.
    btnBrowser := self newButton label: 'Class Browser'; icon: (self iconNamed: #glamorousBrowse); disable.
    btnTranscript := self newButton label: 'Remote Transcript'; icon: (self iconNamed: #glamorousAlignJustify); disable.

    "4. Status"
    statusLabel := self newLabel label: 'Status: Disconnected'.

    "5. Event Wiring"
    btnLogin action: [ self doLogin ].
    btnLogout action: [ self doLogout ].
    
    btnWorkspace action: [ GbsWorkspace new open ].
    btnBrowser action: [ GbsBrowser new open ].
    btnTranscript action: [ 
        | t | t := GbsRemoteTranscript new. 
        t open. t startPolling. 
    ].
]

{ #category : 'initialization' }
GbsLauncher >> initializeWindow: aWindowPresenter [
    aWindowPresenter 
        title: 'GemStone GBS Launcher';
        initialExtent: 350@400.
]
