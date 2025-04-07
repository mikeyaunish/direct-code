Red [
	Title: "base-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
base-plain-style-layout: [
	style base-plain: base extra [
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
	base-plain1: base-plain 245.40.3.0
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view base-plain-style-layout
]