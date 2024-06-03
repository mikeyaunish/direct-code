Red [
	Title: "button-detail-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
button-detail-style-layout: [
	style button-detail: button "?" 20x23 
		extra [
		    message: ""
            setup-style: [                              
                [  
                    input [                  
                        prompt "Detail text"                 
                        detail "Enter the text you want to display when the detail button is clicked."  
                    ]
                    action [                                
                        alter-facet/value 'with compose [ extra/message: (input-value) ]
                    ]
                ]
            ]	        
		]
		on-click [request-message face/extra/message ]
    
    button-detail1: button-detail with [extra/message: "How are you and all of your friends"]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view detail-style-layout
]