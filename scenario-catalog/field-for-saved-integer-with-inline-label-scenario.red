Red [
	Title: "field-for-saved-integer-with-inline-label-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
field-for-saved-integer-with-inline-label-scenario-layout: [
	style label-inline: text "Label Text:" 230.230.230 font-color 0.0.0 right middle
    	extra [
            setup-style: [
                [
                    input [
                        prompt "Label Text:"
                        detail "Enter the text that the label will display"
                    ]
                    action [
                        alter-facet/value 'text input-value 
                    ]
                ]
            ]    
    	]

	style field-saved: Field 80x23 
        extra [
            save-name: ""
            save-filename: copy %""
            setup-style: [
                [
                    input [
                        prompt "Field and Save Name"
                    	detail {Name of of the field to be created. This name is also used as the base name for the filename that contains the field data. The filename format is: "<field-name>-field-data.red" IE: "first-name-field-data.red" }
                    ]
                    action [
                    	if exists? to-file rejoin [ system/options/path (input-value) "-field-data.red" ][
                    		requester-results: prompt/text rejoin [ "The data file name: '" input-value "-field-data.red' already exists. Please enter a different base name for the save file (excluding the '-field-data.red' portion " ] 400x100
                    		while [ exists? rejoin [ system/options/path requester-results "-field-data.red" ]] [
								requester-results: prompt/text rejoin [ "The data file name: '" request-results "-field-data.red' already exists. Please enter a different base name for the save file (excluding the '-field-data.red' portion " ] 400x100                    		
                    			;requester-results: prompt/text rejoin [ "The data file name: '" requester-results "-field-data.red' already exists. Please enter a different base name for the save file (excluding the '-field-data.red' file name extension." ] 400x100
                    		]
                    		input-value: copy requester-results
                    	]
                    	either none? input-value [
                    		false
                    	][
                    		alter-facet/value 'with compose/deep [ extra/save-name: (input-value) ]	
                    		alter-facet/value 'name input-value
                    	]
                    ]
                ]
            ]    
        ] 
        on-create [
            if face/extra/save-name <> "" [
                face/extra/save-filename: to-file rejoin [ system/options/path face/extra/save-name "-field-obj.data"]
                if exists? face/extra/save-filename [
                    face/text: read face/extra/save-filename
                ]
            ]
        ] 
        on-change [
            if face/extra/save-name <> "" [
                write face/extra/save-filename face/text     
            ]
        ]
	style button-x-axis-root: base 230.230.230 0x0
	    extra [
	        start-down: none
	        orig-val: none
	        output-field: none      
	        get-output-field-integer: 0
	        set-output-field: none
	        starting-value: none
	        directions: copy [] 
	        original-color: 230.230.230
	    ]
	    on-down [
	        face/extra/start-down: event/offset/x
	        face/extra/orig-val: face/extra/get-output-field-integer face
	    ]
	    on-up [
            face/extra/set-output-field face  to-string ((face/extra/get-output-field-integer face ) + face/extra/directions/1  )
	        face/extra/start-down: 0
	    ]
	    on-wheel [
	        face/extra/set-output-field face to-string to-integer (( face/extra/get-output-field-integer face) + (event/picked * face/extra/directions/2)  )
	    ]
	    on-over [
	    	if face/extra/start-down <> 0 [
    		    face/extra/set-output-field face to-string to-integer ( face/extra/orig-val +  ( event/offset/x - face/extra/start-down )  )
	    	]
			either event/away? [
	            face/color: face/extra/original-color
	        ] [
	            face/color: 229.241.251
	        ]	    	
	    ]
	    on-create [
	        face/flags: [ all-over ]
			face/extra/get-output-field-integer: func [this-face] [
			    return  either (output-field-value: get to-path reduce [ to-word this-face/extra/output-field 'text ]) = "" [
			        either this-face/extra/starting-value = 'none [
	                    0
			        ][
			            this-face/extra/starting-value
			        ]
	            ][
	                to-safe-integer output-field-value
	            ]
			]
			face/extra/set-output-field: func [this-face v] [
			    do reduce [ to-set-path reduce [ to-word this-face/extra/output-field 'text ] v ]
			]
	        face/extra/start-down: 0
		    face/extra/orig-val: 0
    	]
	style button-x-axis-left: button-x-axis-root 24x24
        with [ extra/directions: [ -1 3 ] ]
		extra [
		    start-down: none 
		    orig-val: none 
		    output-field: none 
		    get-output-field-integer: 0 
		    set-output-field: none 
		    starting-value: none 
		    directions: copy [] 
		    original-color: 230.230.230 
		    setup-style: [
		        [
		            action [
		                alter-facet/value 'with compose/deep [extra/output-field: (to-lit-word objects/2/input-values/1 )]
		            ]
		        ]
		    ]
		]        
		draw [
		    line-width 1 
		    pen 155.155.155 
		    line 0x0 24x0 24x24 0x24 0x0 
		    pen black 
		    line-width 2 
		    line 4x12 20x4 
		    line 4x12 20x20		
		    line-width 0.8 
		    line 13x12 23x12 
		    line 15x10 15x14
		    line 18x10 18x14
		    line 21x10 21x14
	    ]
	style button-x-axis-right: button-x-axis-root 24x24
        with [ extra/directions: [ 1 3 ] ]
		extra [
		    start-down: none 
		    orig-val: none 
		    output-field: none 
		    get-output-field-integer: 0 
		    set-output-field: none 
		    starting-value: none 
		    directions: copy [] 
		    original-color: 230.230.230 
		    setup-style: [
		        [
		            action [
		                alter-facet/value 'with compose/deep [extra/output-field: (to-lit-word objects/2/input-values/1)]
		            ]
		        ]
		    ]
		]           
        draw [
		   line-width 1 
		    pen 155.155.155 
		    line 0x0 24x0 24x24 0x24 0x0 
		    pen black 
		    line-width 2 
		    line 21x12 5x4 
		    line 21x12 5x20        	
		    line-width 0.8 
		    line 3x12 13x12 
		    line 5x10 5x14
		    line 8x10 8x14
		    line 11x10 11x14
		    
        ]
    space 2x2
	label-inline1: label-inline "Age:"
	a-field: field-saved with [ extra/save-name: "a-field" ]
	button-x-axis-left1: button-x-axis-left with [extra/output-field: 'a-field]
	button-x-axis-right1: button-x-axis-right with [extra/output-field: 'a-field]
	space 10x10
	return 
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view field-for-saved-integer-with-inline-label-scenario-layout
]
