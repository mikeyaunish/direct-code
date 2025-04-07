Red [
	Title: "user-script.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [
    comment {This script is designed to work in conjunction with Direct Code. It will not run as a 
             stand alone program because that is not what it is for.}
    change-dir first split-path current-file
]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
git-user-script-layout: [
	style tab-panel-has-tab-position-saved: tab-panel
    extra [
	    save-name: ""
    	save-filename: %""
    	changed?: #(false)
    ]
    on-create [
        if face/extra/save-name <> "" [
            face/extra/save-filename: to-file rejoin [ system/options/path face/extra/save-name "-data.red"]
            if exists? face/extra/save-filename [
                face/selected: load face/extra/save-filename
            ]
        ]    	
    ]
    on-change [
    	face/extra/changed?: #(true)
    ]
	on-up [
		if face/extra/changed? [
			face/extra/changed?: #(false)
	        if face/extra/save-name <> "" [
	            save/all face/extra/save-filename face/selected
	        ]		
        ]
	]
	style area-coder: area 745x200 left  black green bold font-size 13 font-name "Courier New" focus
        extra [
            save-name: ""
            save-filename: copy %""
            has-focus?: #(false)
            run-on-save-object: ""
        ] 
        on-create [
            if face/extra/save-name <> "" [
                face/extra/save-filename: to-file rejoin [ system/options/path face/extra/save-name "-code.red"]
                either exists? face/extra/save-filename [
                    face/text: read face/extra/save-filename
                ][
                	write face/extra/save-filename ""
                ]
            ]
            face/flags: none
        ] 
        on-change [
            if face/extra/save-name <> "" [
                write face/extra/save-filename face/text     
            ]
        ]
        on-key [
            if event/key = #"^K" [
                do face/text
            ]
            if all [ 
            	event/key = #"^O" 
            	find event/flags 'control 
            ][
                editor face/extra/save-filename
            ]
        ]
        rate 00:00:00.25 
        on-time [
            if not face/extra/has-focus? [
                current-data: read face/extra/save-filename
                if current-data <> face/text [
                    face/text: current-data
                    run-on-saved-state: select (get to-word face/extra/run-on-save-object) 'data
                    if run-on-saved-state = #(true) [
                    	do face/text 	
                    ]
                ]
            ]
        ] 
        on-focus [face/extra/has-focus?: true] 
        on-unfocus [
            write face/extra/save-filename face/text
            face/extra/has-focus?: false
        ]
	style button-plain: button "button1"
	style run-button: button-plain "Run [ Ctrl + K ]"
	style open-button: button-plain {Open with Editor [ Ctrl + Shift + O ]}
	style auto-run-check-saved: check "Auto Run? on-create"
        extra [
            save-name: ""
            save-filename: %""
            code-widget: ""
        ] 
        on-create [
            if face/extra/save-name <> "" [
                face/extra/save-filename: to-file rejoin [ system/options/path face/extra/save-name "-code.red"]
                if exists? face/extra/save-filename [
                    face/data: either (load face/extra/save-filename) = 'false [ false ] [ true ]
                ][
                	write face/extra/save-filename ""
                ]
            ]
            if face/data [
           		do get in (get to-word face/extra/code-widget) 'text 
           	]
        ] 
        on-change [
            if face/extra/save-name <> "" [
                save face/extra/save-filename face/data
            ]
        ]
	style check-has-status-saved: check  
        extra [
            save-name: ""
            save-filename: copy %""
        ] 
        on-create [
            if face/extra/save-name <> "" [
                face/extra/save-filename: to-file rejoin [ system/options/path face/extra/save-name "-status-data.red"]
                either exists? face/extra/save-filename [
                    face/data: load face/extra/save-filename
                ][
                	write face/extra/save-filename ""     	
                ]
            ]
        ] 
        on-change [
            if face/extra/save-name <> "" [
                save/all face/extra/save-filename face/data
            ]
        ]
	space 0x1    
	user-script-text1: text "Red Code Snippet Testing Area:" font-size 15 
    return 

    return 
    where-button: button "Window Location Tool"on-click [where-window: layout [
        Title "Drag Window to see its' location" 
        on-create [
            text1/text: to-string where-window/offset
        ] 
        on-move [
            do-actor where-window none 'create
        ] 
        user-script-text2: text 400x25 center
    ] 
    view/options where-window [offset: 300x300]]

    button2: button "show image! format of .PNG file" on-click [
        rf: request-file 
        if rf [
            img: load rf 
            ?? img
        ]
    ]
	return
	
	tab-panel-has-tab-position-saved1: tab-panel-has-tab-position-saved [
	    "Tab-A" [		    a-coder: area-coder with [
		        extra/save-name: "a-coder" 
		        extra/run-on-save-object: "run-when-saved1"
		    ]
	space 2x2
    return
	run-button1: run-button on-click [
	    do a-coder/text
	]
	open-button1: open-button on-click [
	    editor a-coder/extra/save-filename
	]
	space 8x8
	auto-run1: auto-run-check-saved "Run Script when created?" with [
	    extra/save-name: "auto-run1" 
	    extra/code-widget: "a-coder"
	] 
	run-when-saved1: check-has-status-saved "Run when Saved Externally?" with [extra/save-name: "run-when-saved1"]
	return
	    ] 
	    "Tab-B" [		    a-coder1: area-coder with [
		        extra/save-name: "a-coder1" 
		        extra/run-on-save-object: "run-when-saved2"
		    ]
	space 2x2
    return
	run-button2: run-button on-click [
	    do a-coder1/text
	]
	open-button2: open-button on-click [
	    editor a-coder1/extra/save-filename
	]
	space 8x8
	auto-run2: auto-run-check-saved "Run Script when created?" with [
	    extra/save-name: "auto-run2" 
	    extra/code-widget: "a-coder1"
	] 
	run-when-saved2: check-has-status-saved "Run when Saved Externally?" with [extra/save-name: "run-when-saved2"]
	return
	    ] 
	    "Tab-C" [		    a-coder2: area-coder with [
		        extra/save-name: "a-coder2" 
		        extra/run-on-save-object: "run-when-saved3"
		    ]
	space 2x2
    return
	run-button3: run-button on-click [
	    do a-coder2/text
	]
	open-button3: open-button on-click [
	    editor a-coder2/extra/save-filename
	]
	space 8x8
	auto-run3: auto-run-check-saved "Run Script when created?" with [
	    extra/save-name: "auto-run3" 
	    extra/code-widget: "a-coder2"
	] 
	run-when-saved3: check-has-status-saved "Run when Saved Externally?" with [extra/save-name: "run-when-saved3"]
	return
	    ]
	] with [extra/save-name: none]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view/options user-script-layout [ offset: 4x550 ]
]