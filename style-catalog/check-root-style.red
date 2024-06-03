Red [
	Title: "check-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
check-root-style-layout: [
	style check-root: check extra [
	    setup-style: [
	        [
	            input [
	                prompt "Text string" 
	                detail "The text that will display on the object created."
	            ] 
	            action [
	                alter-facet/value 'text input-value
	            ]
	        ]
	    ]
	]
	check11: check-root "Yes or No?"
    
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view check-root-style-layout
]