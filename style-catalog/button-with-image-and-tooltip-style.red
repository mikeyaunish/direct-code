Red [
	Title: "button-with-image-and-tooltip-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
button-with-image-and-tooltip-style-layout: [
	style button-with-image-and-tooltip: button 
		extra [
			normal-image: "" 
			hilight-image: "" 
			now-over?: #(false)
			over-offset: 0x0
			message: {USE> with [ extra/message: "a message" ] to display your own message}  
			boxed: #(false)
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
                        prompt "Tooltip message"
                        detail "Enter the text that you want displayed when the mouse is rolled over the button"
                    ]
                ]
                [  
                    input [
                        prompt "Show message in box?"
                        type "check"
                        detail "By default the message will display in a 'line'. Longer messages will display better in a 'box'."
                    ]
                ]
                [
                    action [
                        alter-facet/value 'with compose/deep [ 
                            extra/message: (input-values/2)
                            extra/boxed: (either input-values/3 [ #(true) ] [ #(false) ])
                            extra/now-over?: false
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
		on-created [
			if not none? face/image [
				face/extra/normal-image: face/image 
				face/extra/hilight-image: get-hilight-image face/image
			]
		] 
		on-over [
			either event/away? [
				face/rate: 1000:00:00
				face/image: face/extra/normal-image 
				face/extra/now-over?: false 
				popup-help/close ""
			] [
				face/image: face/extra/hilight-image 
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
		

	b1: button-with-image-and-tooltip 22x21 %/E/red/direct-code/experiments/move-object/edit-icon-image-22x21.png
		with [ 
			extra/box: 0
			extra/message: "This is the edit icon"
			extra/now-over?: false 
		]
	button-with-image-and-tooltip1: button-with-image-and-tooltip "Hello the3ree" with [
	    extra/box: 0 
	    extra/message: none 
	    extra/now-over?: false
	]
	button-with-image-and-tooltip2: button-with-image-and-tooltip "some" with [
	    extra/box: 0 
	    extra/message: "this" 
	    extra/now-over?: false
	]
	button-with-image-and-tooltip3: button-with-image-and-tooltip 18x22 %/E/red/direct-code/style-catalog/edit-icon-image-large.png with [
	    extra/box: 0 
	    extra/message: "This is the edit icon" 
	    extra/now-over?: false
	]
	
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view button-with-image-and-tooltip-style-layout
]