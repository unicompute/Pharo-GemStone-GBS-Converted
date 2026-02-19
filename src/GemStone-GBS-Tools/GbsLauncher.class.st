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
        GbsServerInterface uniqueInstance libraryPath: inputLibPath text.
        
        session := GbsSessionParameters new
            name: 'Simple Launcher Session';
            gemStoneName: inputStone text;
            username: inputUser text;
            password: inputPass text;
            login.
                    
        GbsSessionParameters currentSession: session.
        
        "Sync ALL open Simple Launchers and Classic Launchers safely"
        UIManager default defer: [
            GbsLauncher allInstancesDo: [ :each | each updateUIState ].
            GbsClassicLauncher allInstancesDo: [ :each | each refreshAll ].
        ].
        
        self inform: 'Connected Successfully!'.
            
    ] on: Error do: [ :ex | 
        self inform: 'Connection Failed: ', ex messageText.
        self updateUIState. "Reset UI on failure"
    ].
]

{ #category : 'actions' }
GbsLauncher >> doLogout [
    [
        | sessionToLogout |
        
        sessionToLogout := GbsSessionParameters allSessions 
            detect: [ :each | each name = 'Simple Launcher Session' ] 
            ifNone: [ GbsSessionParameters currentSession ].
            
        sessionToLogout ifNotNil: [ :s | s logout ].
        
        GbsSessionParameters currentSession: nil.
        
        "Sync ALL open Simple Launchers and Classic Launchers safely"
        UIManager default defer: [
            GbsLauncher allInstancesDo: [ :launcher | launcher updateUIState ].
            GbsClassicLauncher allInstancesDo: [ :launcher | launcher refreshAll ].
        ].
        
    ] on: Error do: [ :ex | self inform: 'Error logging out: ', ex messageText ].
]

{ #category : 'initialization' }
GbsLauncher >> initializePresenters [
    "1. Connection Inputs"
    inputStone := self newTextInput text: 'gs64stone'; placeholder: 'Stone Name'.
    inputUser := self newTextInput text: 'DataCurator'; placeholder: 'Username'.
    inputPass := self newTextInput text: 'swordfish'; placeholder: 'Password'; bePassword.
    inputLibPath := self newTextInput 
        text: '/Users/tariq/GemStone64Bit3.7.4.3-arm64.Darwin/lib/libgcirpc-3.7.4.3-64.dylib';
        placeholder: 'Path to libgcirpc.dylib'.
        
    "2. Action Buttons"
    btnLogin := self newButton label: 'Login'; icon: (self iconNamed: #smallOk).
    btnLogout := self newButton label: 'Logout'; icon: (self iconNamed: #smallCancel).
    
    "3. Tool Buttons"
    btnWorkspace := self newButton label: 'Workspace'; icon: (self iconNamed: #glamorousEdit).
    btnBrowser := self newButton label: 'Class Browser'; icon: (self iconNamed: #glamorousBrowse).
    btnTranscript := self newButton label: 'Remote Transcript'; icon: (self iconNamed: #glamorousAlignJustify).
    
    "4. Status"
    statusLabel := self newLabel label: 'Status: Initializing...'.
    
    "5. Event Wiring"
    btnLogin action: [ self doLogin ].
    btnLogout action: [ self doLogout ].
    btnWorkspace action: [ GbsWorkspace new open ].
    btnBrowser action: [ GbsBrowser new open ].
    btnTranscript action: [ | t | t := GbsRemoteTranscript new. t open. t startPolling. ].
    
    "6. SET INITIAL STATE"
    self updateUIState.
]

{ #category : 'initialization' }
GbsLauncher >> initializeWindow: aWindowPresenter [
    aWindowPresenter 
        title: 'GemStone GBS Launcher';
        initialExtent: 350@400.
]

{ #category : 'updating' }
GbsLauncher >> updateUIState [
    | activeSession |
    
    "Check if our Simple Launcher Session is active globally"
    activeSession := GbsSessionParameters allSessions
        detect: [ :each | each name = 'Simple Launcher Session' ]
        ifNone: [ nil ].

    activeSession ifNotNil: [
        "We are logged in: Disable login, enable tools"
        statusLabel label: 'Status: Connected to ', activeSession gemStoneName.
        btnLogin disable.
        inputStone disable. inputUser disable. inputPass disable. inputLibPath disable.
        btnLogout enable.
        btnWorkspace enable. btnBrowser enable. btnTranscript enable.
    ] ifNil: [
        "We are disconnected: Enable login, disable tools"
        statusLabel label: 'Status: Disconnected'.
        btnLogin enable.
        inputStone enable. inputUser enable. inputPass enable. inputLibPath enable.
        btnLogout disable.
        btnWorkspace disable. btnBrowser disable. btnTranscript disable.
    ].
]
