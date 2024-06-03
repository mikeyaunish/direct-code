Red [
	Title: "button-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
button-root-style-layout: [
    style button-root: button extra [
	    setup-style: [
	        [
	            input [
	                prompt "Text string" 
	                detail "The text that will display on the button."
	            ] 
	            action [
	                alter-facet/value 'text input-value
	            ]
	        ]
	        [
	            input [
	                prompt "Button click code" 
	                detail "The code to run when the button is clicked."
	            ] 
	            action [
	                alter-facet/value 'on-click compose [ (load input-value) ]
	            ]
	        ]
	        
	    ]
	]
	style base-red: base 255.0.0
	base-red1: base-red
    button-root1: button-root "hello" on-click [print "hi"]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view button-root-style-layout
]