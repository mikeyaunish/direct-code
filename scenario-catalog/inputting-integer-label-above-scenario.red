Red [
	Title: "inputting-integer-label-left-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
inputting-integer-label-above-scenario-layout: [
    style label-above: text "Label text" font-color 0.0.0 font-size 12
        extra [
            setup-style: [ ;-- objects/1
                [
                    input [
                        prompt "Label text"
                        detail "Enter the text that you want the label to display"
                    ]
                    action [
                        alter-facet/value 'text input-value 
                    ]
                ]
            ]    
    	]
    		
	style field-root: field extra [
	    setup-style: [ ;-- objects/2
	        [
	            input [
	                prompt "Field name" 
	                detail "The name of the input field to be created."
	            ] 
	            action [
	                alter-facet/value 'name input-value
	            ]
	        ]
	    ]
	]
	style x-axis-button-root: base 230.230.230 0x0
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
	style x-axis-button-left: x-axis-button-root 24x24
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
		    setup-style: [ ;-- objects/3
		        [
		            action [
		                alter-facet/value 'with compose/deep [
		                		extra/output-field: (to-lit-word objects/2/input-values/1)
		                	]
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
	style x-axis-button-right: x-axis-button-root 24x24
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
		    setup-style: [ ;-- objects/4
		        [
		            action [
		                alter-facet/value 'with compose/deep [
		                	extra/output-field: (to-lit-word objects/2/input-values/1)
		               	]
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
	style button-info: base 17x18 info-icon
        extra [ 
            now-over?: 0 
            message: ""
            box: 0
            setup-style: [
                [   
                    input [
                        prompt "Popup text"
                        detail "Enter the text that you want displayed when the mouse is rolled over the info icon"
                    ]
                    action [
                        alter-facet/value 'with compose/deep [ 
                            extra/box: 1 
                            extra/message: (input-value)
                        ]  
                    ]
                ]
            ]                
        ] 
        on-over [
            either event/away? [
                face/extra/now-over?: 0 
                face/image/rgb: complement face/image/rgb 
                show face 
                popup-help/close ""
            ][
                if face/extra/now-over? = 0 [
                    face/image/rgb: complement face/image/rgb 
                    show face 
                    face/extra/now-over?: 1
                    box: either face/extra/box = 0 [
                        false    
                    ][
                        true
                    ]
                    popup-help/offset/:box face/extra/message (face/parent/offset + face/offset + event/offset + 20x20) 
                ]
            ]
        ]
        with [
            extra/message: ""
        ]
    space 1x2
    label-left1: label-above "Shoe size"
	button-info1: button-info with [extra/box: 1 extra/message: "The shoe size to record"]
    return 
    f1: field-root
    x-axis-button-root1: x-axis-button-root
    x-axis-button-left1: x-axis-button-left with [extra/output-field: 'f1]
    x-axis-button-right1: x-axis-button-right with [extra/output-field: 'f1]
    space 10x10
    
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view inputting-integer-label-left-scenario-layout
]
