Class {
	#name : 'GbsClassicLauncher',
	#superclass : 'SpPresenter',
	#instVars : [
		'sessionList',
		'parametersList',
		'mainMenu',
		'btnCommit',
		'btnLogout',
		'btnAbort',
		'btnCurrent',
		'btnBegin',
		'btnBreak',
		'btnLoginLink',
		'btnLoginRpc',
		'btnAdd',
		'btnCopy',
		'btnEdit',
		'btnDelete'
	],
	#category : 'GemStone-GBS-Tools',
	#package : 'GemStone-GBS-Tools'
}

{ #category : 'menus' }
GbsClassicLauncher class >> menuCommandGemStoneOn: aBuilder [
    <worldMenu>
    (aBuilder item: #GemStone)
        order: 25;  "Higher than 20 -> Appears to the right of Library"
        label: 'GemStone';
        icon: (self iconNamed: #smallConfiguration);
        with: [
            (aBuilder item: #Launcher)
                label: 'Classic Launcher';
                action: [ GbsClassicLauncher new open ];
                icon: (self iconNamed: #glamorousGo).
            (aBuilder item: #Login)
                label: 'Login RPC';
                action: [ GbsClassicLauncher new doLoginRpc ];
                icon: (self iconNamed: #smallOk).
        ].
]

{ #category : 'menus' }
GbsClassicLauncher >> buildMenuBar [
    ^ self newMenuBar
        addGroup: [ :group |
            group
                addItem: [ :item | item name: 'Browse'; subMenu: self menuBrowse ];
                addItem: [ :item | item name: 'Parameters'; subMenu: self menuParameters ];
                addItem: [ :item | item name: 'Session'; subMenu: self menuSession ];
                addItem: [ :item | item name: 'Tools'; subMenu: self menuTools ];
                addItem: [ :item | item name: 'Window'; subMenu: self menuWindow ];
                addItem: [ :item | item name: 'About'; action: [ self inform: 'GBS Classic Launcher for Pharo' ] ]
        ].
]

{ #category : 'layout' }
GbsClassicLauncher >> defaultLayout [
    ^ SpBoxLayout newVertical
        add: mainMenu height: self class toolbarHeight;
        add: (SpPanedLayout newVertical
            positionOfSlider: 0.45;
            add: (SpBoxLayout newVertical 
                    add: 'Session Parameters' expand: false;
                    add: parametersList;
                    yourself);
            add: (SpBoxLayout newVertical 
                    add: 'Active Sessions' expand: false;
                    add: sessionList;
                    yourself);
            yourself);
        add: (SpBoxLayout newHorizontal "Row 1 Buttons"
                spacing: 2;
                add: btnLoginLink; add: btnLoginRpc; add: btnAdd; 
                add: btnCopy; add: btnEdit; add: btnDelete;
                yourself) height: 32;
        add: (SpBoxLayout newHorizontal "Row 2 Buttons"
                spacing: 2;
                add: btnCommit; add: btnLogout; add: btnAbort; 
                add: btnCurrent; add: btnBegin; add: btnBreak;
                yourself) height: 32;
        yourself
]

{ #category : 'actions' }
GbsClassicLauncher >> doAbort [
    self withSelectedSession: [ :s | 
        s abortTransaction. 
        self inform: 'Transaction Aborted'. 
    ].
]

{ #category : 'actions' }
GbsClassicLauncher >> doAddParameter [
	| newParam editor window |
	newParam := GbsSessionParameters new.
	editor := GbsSessionParametersEditor new.
	editor setModel: newParam.
	
	"Pass the save action to the editor"
	editor onAccept: [ 
		GbsSessionParameters addParameter: newParam.
		self refreshAll.
	].
	
	"Open as a standard window (No double buttons)"
	window := editor open.
	window centered.
]

{ #category : 'actions' }
GbsClassicLauncher >> doBegin [
    self withSelectedSession: [ :s | 
        s beginTransaction. 
        self inform: 'Manual Transaction Started'. 
    ].
]

{ #category : 'actions' }
GbsClassicLauncher >> doBreak [
    self withSelectedSession: [ :s | 
        s sendInterrupt. 
        self inform: 'Interrupt Signal Sent'. 
    ].
]

{ #category : 'actions' }
GbsClassicLauncher >> doCommit [
    self withSelectedSession: [ :s | 
        s commitTransaction. 
        self inform: 'Transaction Committed'. 
        self refreshSessionList. 
    ].
]

{ #category : 'actions' }
GbsClassicLauncher >> doCopyParameter [
    parametersList selection selectedItem ifNotNil: [ :param |
        | newParam |
        newParam := param copy.
        newParam name: param name, ' (copy)'.
        GbsSessionParameters addParameter: newParam.
        self refreshAll.
    ].
]

{ #category : 'actions' }
GbsClassicLauncher >> doDeleteParameter [
    parametersList selection selectedItem ifNotNil: [ :param |
        GbsSessionParameters removeParameter: param.
        self refreshAll.
    ].
]

{ #category : 'actions' }
GbsClassicLauncher >> doEditParameter [
	parametersList selection selectedItem ifNotNil: [ :param |
		| editor window |
		editor := GbsSessionParametersEditor new.
		editor setModel: param.
		
		editor onAccept: [ 
			self refreshAll. 
		].
		
		window := editor open.
		window centered.
	].
]

{ #category : 'actions' }
GbsClassicLauncher >> doLoginRpc [
    parametersList selection selectedItem ifNotNil: [ :params |
        
        "Show progress"
        UIManager default showWaitCursorWhile: [ 
            [
                "Use the SELECTED object to login"
                params login.
                
                "Update the UI"
                self refreshAll.
                
                params isConnected 
                    ifTrue: [ 
                        GbsSessionParameters currentSession: params.
                        self inform: 'Login Successful: ', params name 
                    ].
                
            ] on: Error do: [ :ex | 
                self inform: 'Login Error: ', ex messageText.
                ex inspect. 
            ]
        ].
    ] ifNil: [ self inform: 'Please select a configuration first.' ].
]

{ #category : 'actions' }
GbsClassicLauncher >> doLogout [
    sessionList selection selectedItem ifNotNil: [ :session |
        session logout.
        self refreshAll.
    ].
]

{ #category : 'initialization' }
GbsClassicLauncher >> initializePresenters [
    mainMenu := self buildMenuBar.

    "Lists"
    parametersList := self newTable.
    parametersList addColumn: (SpStringTableColumn title: 'Name' evaluated: #name).
    parametersList beSingleSelection.

    sessionList := self newTable.
    sessionList
        addColumn: (SpStringTableColumn title: 'Session ID' evaluated: [ :s | s sessionId asString ]);
        addColumn: (SpStringTableColumn title: 'Name' evaluated: [ :s | s name ]);
        addColumn: (SpStringTableColumn title: 'State' evaluated: [ :s | s isConnected ifTrue: ['Connected'] ifFalse: ['Disconnected'] ]).
    sessionList beSingleSelection.

    "Buttons"
    "UPDATED: Map Login Link to the RPC login logic"
    btnLoginLink := self newButton 
        label: 'Login Link'; 
        icon: (self iconNamed: #glamorousGo); 
        action: [ self doLoginRpc ].
    
    btnLoginRpc  := self newButton 
        label: 'Login RPC'; 
        icon: (self iconNamed: #glamorousGo); 
        action: [ self doLoginRpc ].
    
    btnAdd       := self newButton label: 'Add...'; icon: (self iconNamed: #add); action: [ self doAddParameter ].
    btnCopy      := self newButton label: 'Copy'; icon: (self iconNamed: #smallCopy); action: [ self doCopyParameter ].
    btnEdit      := self newButton label: 'Edit...'; icon: (self iconNamed: #edit); action: [ self doEditParameter ].
    btnDelete    := self newButton label: 'Delete'; icon: (self iconNamed: #delete); action: [ self doDeleteParameter ].

    btnCommit := self newButton label: 'Commit'; icon: (self iconNamed: #smallSave); action: [ self doCommit ].
    btnLogout := self newButton label: 'Logout'; icon: (self iconNamed: #smallCancel); action: [ self doLogout ].
    btnAbort  := self newButton label: 'Abort'; icon: (self iconNamed: #smallDelete); action: [ self doAbort ].
    btnCurrent:= self newButton label: 'Current'; icon: (self iconNamed: #smallForward); action: [ self makeCurrent ].
    btnBegin  := self newButton label: 'Begin'; icon: (self iconNamed: #smallUpdate); action: [ self doBegin ].
    btnBreak  := self newButton label: 'Break'; icon: (self iconNamed: #smallCancel); action: [ self doBreak ].

    self refreshAll.
]

{ #category : 'initialization' }
GbsClassicLauncher >> initializeWindow: aWindow [
	aWindow 
		title: 'GemStone Launcher';
		initialExtent: 500@400.
]

{ #category : 'actions' }
GbsClassicLauncher >> makeCurrent [
    self withSelectedSession: [ :s | 
        GbsSessionParameters currentSession: s.
        self inform: 'Session set as Current'.
        self refreshSessionList.
    ].
]

{ #category : 'menus' }
GbsClassicLauncher >> menuBrowse [
    ^ self newMenu
        addItem: [ :item | item name: 'System'; action: [ self inform: 'System Browser TODO' ] ];
        addItem: [ :item | item name: 'Class...'; action: [ GbsBrowser new open ] ];
        addItem: [ :item | item name: 'Symbol Dictionary...'; action: [ self inform: 'Dict Browser TODO' ] ];
        yourself.
]

{ #category : 'menus' }
GbsClassicLauncher >> menuParameters [
    ^ self newMenu
        addItem: [ :item | item name: 'Add...'; action: [ self inform: 'Add Parameter' ] ];
        addItem: [ :item | item name: 'Edit'; action: [ self inform: 'Edit Parameter' ] ];
        addItem: [ :item | item name: 'Delete'; action: [ self inform: 'Delete Parameter' ] ];
        yourself.
]

{ #category : 'menus' }
GbsClassicLauncher >> menuSession [
    ^ self newMenu
        addItem: [ :item | item name: 'Login'; action: [ self inform: 'Use the main Launcher to create sessions' ] ];
        addItem: [ :item | item name: 'Logout'; action: [ self doLogout ] ];
        addItem: [ :item | item name: 'Commit'; action: [ self doCommit ] ];
        addItem: [ :item | item name: 'Abort'; action: [ self doAbort ] ];
        yourself.
]

{ #category : 'menus' }
GbsClassicLauncher >> menuTools [
    ^ self newMenu
        addItem: [ :item | 
            item name: 'Workspace'; 
            action: [ GbsWorkspace new open ] ];
        addItem: [ :item | 
            item name: 'Transcript'; 
            action: [ | t | 
                t := GbsRemoteTranscript new. 
                t open. 
                t startPolling "Fixed: Calling on the presenter, not the window" ] ];
        yourself.
]

{ #category : 'menus' }
GbsClassicLauncher >> menuWindow [
    ^ self newMenu
        addItem: [ :item | item name: 'Refresh'; action: [ self refreshSessionList ] ];
        addItem: [ :item | item name: 'Close'; action: [ self delete ] ];
        yourself.
]

{ #category : 'actions' }
GbsClassicLauncher >> refreshAll [
	"Get parameters and sessions from the shared registry"
	parametersList items: GbsSessionParameters allParameters.
	sessionList items: GbsSessionParameters allSessions.
	
	"Update the selection if a current session exists"
	GbsSessionParameters currentSession ifNotNil: [ :current |
		sessionList selectItem: current
	].
]

{ #category : 'actions' }
GbsClassicLauncher >> refreshSessionList [
    sessionList items: GbsSessionParameters allSessions.
    parametersList items: GbsSessionParameters allParameters. "Assuming this collection exists"
    GbsSessionParameters currentSession ifNotNil: [ :s | sessionList selectItem: s ].
]

{ #category : 'private' }
GbsClassicLauncher >> withSelectedSession: aBlock [
    sessionList selection selectedItem 
        ifNotNil: [ :session | aBlock value: session ]
        ifNil: [ self inform: 'Please select a session from the list.' ].
]
