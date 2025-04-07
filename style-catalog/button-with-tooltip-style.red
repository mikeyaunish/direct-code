Red [
	Title: "button-with-tooltip-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
button-with-tooltip-style-layout: [
	style button-with-tooltip: button
		rate 99:99:99 
        extra [ 
            now-over?: #(false)
            over-offset: 0x0 
            message: {Add with [ extra/message: "a message" ] to display your own message} 
            boxed: #(false)
            setup-style: [
		        [
		            input [
		                prompt "Button text" 
		                detail "The text that will display on the button."
		            ] 
		            action [
		                alter-facet/value 'text input-value
		            ]
		        ]
                [   
                    input [
                        prompt "Tooltip text"
                        detail "Enter the text that you want displayed when the mouse is rolled over the button"
                    ]
                ]
                [  
                    input [
                        prompt "Show info in box?"
                        type "check"
                        detail "By default info will display in a 'line'. Longer text strings will display better in a 'box'."
                    ]
                ]
                [
                    action [
                        alter-facet/value 'with compose/deep [ 
                            extra/boxed: (either input-values/3 [ #(true) ] [ #(false) ])
                            extra/message: (input-values/2)
                        ]  
                    ]
                ]
                [
                	action [
                		alter-facet/value 'on-click compose [
							face/rate: 1000:00:00 
							if face/extra/now-over? [
							    face/extra/now-over?: false 
							    popup-help/close "" 
							    do-events
							]                			
                		]
                	]
                ]
            ]                
        ]
        on-create [ face/extra/now-over?: #(false)]
        on-over [
            either event/away? [
            	face/rate: 99:99:99	
	        	if face/extra/now-over? [
	        		face/extra/now-over?: #(false)
	        		popup-help/close ""
	        	]				            
	        ][
                if not face/extra/now-over?  [
					face/rate: 00:00:00.55
					face/extra/over-offset: event/offset 				                
				]
            ]
        ]
        on-time [
        	face/rate: 1000:00:00
        	face/extra/now-over?: #(true)
        	box: face/extra/boxed 
        	popup-help/offset/:box face/extra/message ((get-absolute-offset face) + face/extra/over-offset + -12x14) 
        ]	
		
	button-with-tooltip3: button-with-tooltip "Harry" with [
	    extra/boxed: false 
	    extra/message: "was very much like a gorrila"
	]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view button-with-tooltip-style-layout
]