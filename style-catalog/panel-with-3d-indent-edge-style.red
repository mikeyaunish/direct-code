Red [
	Title: "panel-with-3d-indent-edge-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
panel-with-3d-indent-edge-style-layout: [
	style panel-with-3d-indent-edge: panel 208.239.210.0 	
		on-created [
			face/draw: compose/deep [
			    line-width 6 
			    pen white
			    line (to-pair reduce [ (face/size/x - 3) 0 ]) (to-pair reduce [ (face/size/x - 3)  face/size/y ]) ;-- East
			    line (to-pair reduce [ 0 (face/size/y - 3) ]) (to-pair reduce [ (face/size/x )  (face/size/y - 3) ]) ;-- South
				line-width 8
			    pen pewter
			    line 0x2 (to-pair reduce [ (face/size/x) 2 ]) ;-- North
			    line 0x2 (to-pair reduce [ 0 (face/size/y + 2)]) ;-- West
			    pen white
			    line-width 1
			    fill-pen white
			    polygon ;-- SW corner
			    	(to-pair reduce [ 5 (face/size/y - 5)]) 	;-- NE of corner
			    	(to-pair reduce [ 0 (face/size/y)]) 		;-- SW of corner
			    	(to-pair reduce [ 5 (face/size/y )])		;-- SE of corner
			    	(to-pair reduce [ 5 (face/size/y - 5)]) 	;-- return
			    polygon
			    	(to-pair reduce [ (face/size/x ) 0 ]) (to-pair reduce [ (face/size/x ) 1 ]) 					;-- NE of corner
			    	(to-pair reduce [ (face/size/x - 5 ) 6] ) 	;-- SW of corner
			    	(to-pair reduce [ (face/size/x) 6 ])		;-- SE of corner
			    	(to-pair reduce [ (face/size/x ) 0 ]) (to-pair reduce [ (face/size/x ) 1 ]) 					;-- NE of corner
			]
		]
		extra [
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
	panel-with-3d-indent-edge1: panel-with-3d-indent-edge [panel-with-3d-indent-edge1-button1: button "panel-with-3d-indent-edge1-button1"]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view panel-with-3d-indent-edge-style-layout
]