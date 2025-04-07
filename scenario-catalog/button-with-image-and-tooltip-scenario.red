Red [
	Title: "button-with-image-and-tooltip-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
button-with-image-and-tooltip-scenario-layout: [
	style button-with-image-and-tooltip: button  
		extra [
			normal-image: ""
			hilight-image: ""
            over-offset: 0x0
            message: ""
            box: 0
            popped?: #(false)			
		    setup-style: [
		        [
		            input [
		                prompt "Image Filename" 
		                type "file" 
		                detail "The filename of the image you want to use"
		            ] 
		            action [
		                alter-facet/value 'file to-valid-file input-value
		                x: load to-file input-value
		                alter-facet/value 'size x/size
		            ]
		        ]
                [  
                    input [
                        prompt "Show Tooltip in box?"
                        type "check"
                        detail "By default Tooltip text will display in a 'line'. Longer text strings will display better in a 'box'."
                    ]
                ]
                [   
                    input [
                        prompt "Tooltip text"
                        detail "Enter the Tooltip text that you want displayed when the mouse is rolled over the button"
                    ]
                ]
                [
                    action [
                        box-state: either input-values/2 [ 1 ] [ 0 ]
                        alter-facet/value 'with compose/deep [ 
                            extra/box: (box-state)
                            extra/message: (input-values/3)
                        ]  
                    ]
                ]
		        
		    ]
		]
		on-created [
			if not none? face/image [
				face/extra/normal-image: face/image
				face/extra/hilight-image: get-hilight-image face/image
			]
		]
	    on-over [ 
			either event/away? [ 						;-- on-away
				face/image: face/extra/normal-image
				face/rate: 99:99:99
				if face/extra/popped? [
					face/extra/popped?: #(false)
					popup-help/close ""	
				]             
				
			][ 											;-- on-over
				face/image: face/extra/hilight-image 
            	face/rate: 00:00:00.5
            	face/extra/over-offset: event/offset
			]
		]
		on-time [
			face/rate: 99:99:99
			face/extra/popped?: #(true) 
			box: either face/extra/box = 0 [ false ][ true ]
			popup-help/offset/:box face/extra/message ((get-absolute-offset face) + face/extra/over-offset + 10x0)
		]		
	button-with-image-and-tooltip1: button-with-image-and-tooltip 22x22 %/E/red/direct-code/images/zero-out-icon-normal.png
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view button-with-image-and-tooltip-scenario-layout
]
