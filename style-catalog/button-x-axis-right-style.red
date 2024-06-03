Red [
	Title: "button-x-axis-right-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
button-x-axis-right-style-layout: [
    style button-x-axis-root: base 230.230.230 0x0
	    extra [
	        start-down: none
	        orig-val: none
	        output-field: none      
	        get-output-field-integer: 0
	        set-output-field: none
	        starting-value: none
	        directions: copy [] ;-- first value is on-click second value is on-wheel
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
		            input [
		                prompt "Output field name" 
		                detail "Specify which existing field will receive the output from this button."
		            ] 
		            action [
		                alter-facet/value 'with compose/deep [extra/output-field: (to-lit-word input-value)]
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
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view button-x-axis-right-style-layout
]