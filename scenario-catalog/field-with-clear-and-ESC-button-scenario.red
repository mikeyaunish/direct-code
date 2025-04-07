Red [
	Title: "field-with-clear-and-ESC-button-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
field-with-clear-and-ESC-button-scenario-layout: [
	style field-with-clear: field 
		on-key-up [if event/key = #"^[" [
	    	face/text: copy ""
		]
	] extra [
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
	style clear-button: button "Clear" 40x23 extra [
	    setup-style: [
	        [
	            action [
	                alter-facet/value 'on-click 
	                	compose/deep [ 
	                		set to-path reduce [ ( to-lit-word objects/1/object-name) 'text] copy ""
	                		
	                	]
	            ]
	        ]
	    ]
	]
	
	a-fld: field-with-clear
	space 2x2
	clear-button1: clear-button on-click [
	    set to-path reduce ['a-fld 'text] ""
	]
	space 10x10
	return 
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view field-with-clear-and-ESC-button-scenario-layout
]
