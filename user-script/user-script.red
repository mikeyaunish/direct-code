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
user-script-layout: [
	title "Direct Code User Script"
	space 0x1    
	text1: text "Red Code Snippet Testing Area:" font-size 15 
    return 
    
	style area-coder: area 745x200 left  black green bold font-size 13 font-name "Courier New" focus
        extra [
            save-name: ""
            save-filename: copy %""
            has-focus?: false 
        ] 
        on-create [
            if face/extra/save-name <> "" [
                face/extra/save-filename: to-file rejoin [ root-path %user-script/ face/extra/save-name ".data"]
                if exists? face/extra/save-filename [
                    face/text: read face/extra/save-filename
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
            if event/key = #"^O" [
                editor face/extra/save-filename
            ]
        ]
        rate 00:00:00.25 
        on-time [
            if not face/extra/has-focus? [
                current-data: read face/extra/save-filename
                if current-data <> face/text [
                    face/text: current-data
                    do face/text 
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
	style open-button: button-plain "Open with Editor [ Ctrl + O ]"
	tab-panel1: tab-panel  [
		"Snippet 1" [
		    red-snippet1: area-coder with [extra/save-name: "red-snippet1"]
			space 2x2
		    return
			run-button1: run-button on-click [
			    do red-snippet1/text
			]
		    
			open-button1: open-button on-click [
			    editor red-snippet1/extra/save-filename
			]
			return 
		    
		    mk-button: button "Make Button from Code above with button label ->"  
		    	on-click [
		    		btn-label: any [btn-label-field/text ""] 
				    insert-vid-object/with-on-click/with-text "button" (to-block red-snippet1/text) btn-label
				]
		    bl: text font-size 13 "Button Label:" right
		    btn-label-field: field  218
		] 
		"Snippet 2" [
		    red-snippet2: area-coder with [extra/save-name: "red-snippet2"]
			space 2x2
		    return
			run-button1: run-button on-click [
			    do red-snippet2/text
			]
		    
			open-button1: open-button on-click [
			    editor red-snippet2/extra/save-filename
			]
		]
	]   
	space 10x10 
    return 
    where-button: button "Window Location Tool"on-click [where-window: layout [
        Title "Drag Window to see its' location" 
        on-create [
            text1/text: to-string where-window/offset
        ] 
        on-move [
            do-actor where-window none 'create
        ] 
        text1: text 400x25 center
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
	
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view/options user-script-layout [ offset: 4x550 ]
]