Red [
	Title: "group-box-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
group-box-plain-style-layout: [
    style group-box-plain: group-box "group-box1" extra [
	    setup-style: [
	        [
	            input [
	                prompt "Text string"
	                detail "The label text that will display on the group-box."
	            ]
	            action [
	                alter-facet/value 'text input-value
	                alter-facet/value 'layout-block compose/deep [(to-set-word rejoin [ object-name "-button" ] ) button (to-string object-name)]
	            ]
	        ]
	    ]
	]
   
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view group-box-plain-style-layout
]