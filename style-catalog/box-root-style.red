Red [
	Title: "box-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
box-root-style-layout: [
    style box-root: box 250.250.250 extra [
	    setup-style: [
	        [
	            input [
	                prompt "Color"
	                type "color" 
	                detail "Enter the color you want the box to be. Use the tuple format RRR.GGG.BBB.TRANSPARENT. IE: 100.100.200.0 "
	            ] 
	            action [
	                alter-facet/value 'color (to-tuple input-value)
	            ]
	        ]
	    ]
	]
	box-root1: box-root 0.255.0.220
	box-root1-1: box-root 200.0.0.220 loose
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view box-root-style-layout
]