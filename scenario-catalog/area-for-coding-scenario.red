Red [
	Title: "area-for-coding-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
area-for-coding-scenario-layout: [
	style area-coder: area 745x200 left  black 0.255.0 bold font-size 13 font-name "Consolas" focus
        extra [
            save-filename: %""
            has-focus?: #(false)
            run-on-save-object: ""    
        ] 
        on-create [
			either exists? face/extra/save-filename [
				face/text: read face/extra/save-filename
			][
				write face/extra/save-filename {print "Hello, World"}
			]
            face/flags: none
        ] 
        on-change [
			if face/extra/save-filename <> %"" [
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
            	if exists? face/extra/save-filename [
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
        ] 
        on-focus [face/extra/has-focus?: true] 
        on-unfocus [
			if face/extra/save-filename <> %"" [
				write face/extra/save-filename face/text
			]            
            face/extra/has-focus?: false
        ]
	style button-plain: button "button1"
	style afc-run-button: button "Run [ Ctrl + K ]" extra [
	    setup-style: [
	        [
	            action [
	                alter-facet/value 'on-click compose/deep [
	                    do (to-path reduce [ to-word objects/1/object-name 'text ]) 
	                ]
	            ]
	        ]
	    ]
	]
	style open-button: button-plain {Open with Editor [ Ctrl + Shift + O ]} extra [
	    setup-style: [
	        [
	            action [
	                alter-facet/value 'on-click compose/deep [
	                    editor (to-path reduce [ to-word objects/1/object-name 'extra 'save-filename ]) 
	                ]
	            ]
	        ]
	    ]
	]
	style auto-run-check-saved: check "Auto Run? on-create"
        extra [
            save-filename: %""
            code-widget: ""
            setup-style: [
				[
                    action [
						full-filename: find-unused-filename rejoin [
							system/options/path rejoin 
							["vid-" object-name ".red"]
						] 
                        alter-facet/value 'with compose/deep [ 
                        	extra/code-widget: (objects/1/object-name)
							extra/save-filename: (second split-path full-filename)
                        ]                   
                    ]
                ]
            ]    
        ] 
        on-create [
			if exists? face/extra/save-filename [
				face/data: load face/extra/save-filename
			]
            if face/data [
           		do get in (get to-word face/extra/code-widget) 'text 
           	]
        ] 
        on-change [
            if face/extra/save-filename <> %"" [
                save/all face/extra/save-filename face/data
            ]
        ]

	style check-has-status-saved: check  
        extra [
            save-filename: %""
            setup-style: [
                [
                    action [
						full-filename: find-unused-filename rejoin [
							system/options/path rejoin 
							["vid-" object-name "-check.data"]
						] 
						area-filename: find-unused-filename rejoin [ 
							system/options/path rejoin               
							["vid-" objects/1/object-name ".red"]        
						]                                            
						
						alter-facet/value 'with compose/deep [extra/save-filename: (second split-path full-filename)] 
                    	modify-facet/value vid-code/text objects/1/object-name 'with compose/deep [ 
                    		extra/run-on-save-object: (object-name)
                    		extra/save-filename: (second split-path area-filename)
                    	]                        
                    ]
                ]
            ]    
        ] 
        on-create [
			if exists? face/extra/save-filename [
				face/data: load face/extra/save-filename
			]                
        ] 
        on-change [
            if face/extra/save-filename <> %"" [
                save/all face/extra/save-filename face/data
            ]
        ]   
             
    area-coder1: area-coder with [
    	extra/save-filename: %a-coder-area.text 
    	extra/run-on-save-object: "run-when-saved1"
    ]
    
	space 2x2
    return
	run-button1: afc-run-button on-click [
		do a-coder/text 
	]
	open-button1: open-button on-click [
		editor a-coder/extra/save-filename 
	]
	space 8x8
	auto-run1: auto-run-check-saved "Run Script when created?" 
	run-when-saved1: check-has-status-saved "Run when Saved Externally?" 
	return 
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view area-for-coding-scenario-layout
]
