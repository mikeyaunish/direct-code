Red [
	Title: "field-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [
]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
field-root-style-layout: [ 
    style field-root: field extra [
	    setup-style: [
	        [
	            input [
	                prompt "Field name" 
	                detail "The name of the field to be created."
	            ] 
	            action [
	                alter-facet/value 'name input-value
	            ]
	        ]
	    ]
	]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view field-root-style-layout
]