Red [
	Title: "radio-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [
]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
radio-root-style-layout: [ 
    style radio-root: radio extra [
	    setup-style: [
	        [
	            input [
	                prompt "Radio Text label" 
	                detail "The text that will display next to the radio button."
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
	view radio-root-style-layout
]