Red [
	Title: "text-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
text-root-style-layout: [
	style text-root: text extra [
	    setup-style: [
	        [
	            input [
	                prompt "Text string" 
	                detail "The text that you want displayed."
	            ] 
	            action [
	                alter-facet/value 'text input-value
	            ]
	        ]
	    ]
	]
	text-root1: text-root "Hello"
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view text-root-style-layout
]