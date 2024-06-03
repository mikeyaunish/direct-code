Red [
	Title: "base-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
base-root-style-layout: [
	style base-root: base extra [
	    setup-style: [
	        [
	            input [
	                prompt "Color" 
	                type "color"
	                detail "Enter the color you want the base to be. Use the tuple format RRR.GGG.BBB.TRANSPARENT. IE: 100.200.100.0 "
	            ] 
	            action [
	                alter-facet/value 'color to-tuple input-value
	            ]
	        ]
	    ]
	]
	style calendar-root: calendar
	base11: base-root 80.181.86.0
    
	calendar-root1: calendar-root 9-Apr-2024
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view base-root-style-layout
]