Red [
	Title: "drop-down-with-run-code-button-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
drop-down-with-run-code-button-scenario-layout: [
	style drop-down-do-code: drop-down data [] extra [
		    setup-style: [
		        [
		            action [
		                alter-facet/value 'data compose/deep [
		                	"Hello"   [ print "hello"  ]
		                	"Goodbye" [ print "goodbye"]
		                	"Done"    [ print "done"   ]
		                ]
		            ]
		        ]
		    ]
		]
		on-create [
			do-selected-drop-down: function [face] [
				do pick face/data (face/selected * 2 )
			]
		] 
	style drop-down-run-button: button "RUN" 35x23 on-click [do-selected-drop-down drop-down-do-code1] extra [
	    setup-style: [
	        [
	            action [
	                alter-facet/value 'on-click compose/deep [
	                    do-selected-drop-down (to-word objects/1/object-name)
	                ]
	            ]
	        ]
	    ]
	]
	drop-down-do-code1: drop-down-do-code
	space 0x0
	button11: drop-down-run-button
	space 10x10
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view drop-down-with-run-code-button-scenario-layout
]
