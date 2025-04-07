Red [
	Title: "check-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
check-plain-style-layout: [
	style check-plain: check extra [
	    setup-style: [
	        [
	            input [
	                prompt "Check Box Label" 
	                detail "The text that will display next to the check box."
	            ] 
	            action [
	                alter-facet/value 'text input-value
	            ]
	        ]
	    ]
	]
    
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view check-plain-style-layout
]