Red [
	Title: "panel-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
panel-plain-style-layout: [
    style panel-plain: panel "panel1" 250.250.250 extra [
	    setup-style: [
	        [
	            action [
	                alter-facet/value 'layout-block compose/deep [ 
	                		(to-set-word rejoin [ object-name "-button1" ] ) button (rejoin [ object-name "-button1"] ) 
	                ]
	            ]
	        ]
	    ]
	]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view panel-plain-style-layout
]