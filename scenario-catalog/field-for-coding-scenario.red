Red [
	Title: "field-for-coding-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
field-for-coding-scenario-layout: [
	style field-coder: Field 900x26 0.9.0.0 bold font-name "Consolas" font-size 13 font-color 0.255.0
        extra [
            save-filename:  %"" 
            has-focus?: #(false) 
            setup-style: [
                [
                    action [
						full-filename: find-unused-filename rejoin [
							system/options/path 
							rejoin ["vid-" object-name ".red"]
						] 
						alter-facet/value 'with compose/deep [extra/save-filename: (second split-path full-filename)]
                    ]
                ]
            ]
        ] 
        on-create [
			either exists? face/extra/save-filename [
				face/text: read face/extra/save-filename
			][
				write face/extra/save-filename {print "Hello, World"}
			]			
        ] 
        on-change [
            if face/extra/save-filename <> %"" [
                write face/extra/save-filename face/text
            ]
        ]
        on-enter [
            do face/text 
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
                    do face/text 
                ]
            ]
        ] 
        on-focus [face/extra/has-focus?: true] 
        on-unfocus [
            write face/extra/save-filename face/text
            face/extra/has-focus?: false
        ]
        
	style ffc-run-button: button extra [
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
	
	field-coder1: field-coder 850x26 with [ extra/save-filename: %vid-f1-field-code-snippet.red ] 
	space 0x0
	run-button1: ffc-run-button "RUN" 36x25 on-click [do field-coder1/text]
	space 10x10
	return 
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view field-for-coding-scenario-layout
]
