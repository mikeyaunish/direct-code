Red [
	Title: "area-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
area-root-style-layout: [
    style area-root: area extra [
	    setup-style: [
	        [
	            input [
	                prompt "Size" 
	                detail "The size of the area. Enter the size in WWxHH pair format. IE: 200x100 "
	            ] 
	            action [
	                alter-facet/value 'size to-pair input-value
	            ]
	        ]
	    ]
	]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view area-root-style-layout
]