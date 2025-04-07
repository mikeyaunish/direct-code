Red [
	Title: "tab-panel-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
tab-panel-plain-style-layout: [
    style tab-panel-plain: tab-panel
    extra [
	    setup-style: [
	        [
	            action [
	                alter-facet/value 'layout-block compose/deep [
	                	"Tab-A" [ (to-set-word  rejoin [ object-name "-tab-a"]) button (to-string rejoin [ object-name "-tab-a"]) ]
	                	"Tab-B" [ (to-set-word  rejoin [ object-name "-tab-b"]) button (to-string rejoin [ object-name "-tab-b"]) ]
	                	"Tab-C" [ (to-set-word  rejoin [ object-name "-tab-c"]) button (to-string rejoin [ object-name "-tab-c"]) ]
	                ]
	            ]
	        ]
	    ]
	]

]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view tab-panel-plain-style-layout
]