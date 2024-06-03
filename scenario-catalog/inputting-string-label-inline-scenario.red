Red [
	Title: "inputting-string-label-inline-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
inputting-string-label-inline-scenario-layout: [
	style label-inline: text "Label Text:" 230.230.230 font-color 0.0.0 right middle
    	extra [
            setup-style: [
                [
                    input [
                        prompt "Field Label Text"
                        detail "Enter the text that the field label will display"
                    ]
                    action [
                        alter-facet/value 'text input-value 
                    ]
                ]
            ]    
    	]
	style field-root: field extra [
	    setup-style: [
	        [
	            input [
	                prompt "Field name" 
	                detail "The name of the field to be created"
	            ] 
	            action [
	                alter-facet/value 'name input-value
	            ]
	        ]
	    ]
	]
	space 2x10
	label-inline1: label-inline "Name:"
	field-root1: field-root
	space 10x10
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view inputting-string-label-inline-scenario-layout
]
