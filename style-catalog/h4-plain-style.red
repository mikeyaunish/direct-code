Red [
	Title: "h4-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
h4-plain-style-layout: [
    style h4-plain: h4 extra [
	    setup-style: [
	        [
	            input [
	                prompt "Text string" 
	                detail "The text that will display."
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
	view h4-plain-style-layout
]