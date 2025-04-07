Red [
	Title: "panel-with-vertical-scrolling-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
panel-with-vertical-scrolling-scenario-layout: [
	style vsp-underlay: panel gray 
		extra [
		    vsp-viewport-panel: "" 
		    setup-style: [ ;-- objects/1
		        [
		            input [
		                prompt "Naming Prefix" 
		                detail "Enter a string that will be the prefix of the ^/vertical-scroll-panel objects. Those objects are: vsp-viewport, vsp-underlay, vsp-panel and vsp-scroller. This is to ensure that their aren't any naming conflicts when using more than one vertical scroll panel in a layout."
		            ] 
		            action [
		            	alter-facet/value 'name (rejoin [ (input-value) "-vsp-underlay" ] )
		                alter-facet/value 'with compose/deep [ 
		                	extra/vsp-viewport-panel: (rejoin [ (input-value) "-vsp-viewport" ] )
		                ]
		            ]
		        ]
		    ]
		]
   		on-create [
		    set 'move-vertical-scroll-panel func [
		    	vertical-scroll-panel [object!]
		        /wheel wheel-data 
		    ][
		    	viewport-object: get to-word vertical-scroll-panel/extra/vsp-viewport-panel
		        max-percent: ( 1 - (viewport-object/size/y / vertical-scroll-panel/size/y ))
		        scroller-object: get to-word vertical-scroll-panel/extra/vsp-scroller
		        either wheel [
		            scroller-object/data: max ((min max-percent scroller-object/data - (wheel-data / (max-percent * 11 )) )) 0
		        ][
		            scroller-object/data: max (min max-percent scroller-object/data) 0
		        ]
		        vertical-scroll-panel/offset/y: to integer! negate vertical-scroll-panel/size/y * scroller-object/data
		    ]
		    
		    set 'modify-scroll-panel func [ 
		    	vertical-scroll-panel [object!]
		    	layout-block [block!]
		    ][
		        vertical-scroll-panel/pane: layout/only layout-block
				vertical-scroll-panel/size: select layout layout-block 'size
				scroller-object: get to-word vertical-scroll-panel/extra/vsp-scroller
				viewport-object: get to-word vertical-scroll-panel/extra/vsp-viewport-panel
		        scroller-object/selected: (viewport-object/size/y / vertical-scroll-panel/size/y )
		        scroller-object/data: 0.0
		        move-vertical-scroll-panel vertical-scroll-panel 
		    ]		
		        
   			vsp-viewport-panel-object: get to-word face/extra/vsp-viewport-panel 
   			;-- face/offset: to-pair reduce [ 7 (vsp-viewport-panel-object/offset/y - 3 ) ]
   			face/size: vsp-viewport-panel-object/size + 26x6 
   		]

    style vertical-scroll-panel: panel   ;-- objects/2
    	extra [ 
    		vsp-scroller: ""
    		vsp-viewport-panel: ""

    	]    	    	
   		
    style vsp-viewport-panel: panel  
   	    extra [
   	        vertical-scroll-panel: "" 
   	        vsp-scroller: "" 
   	        setup-style: [ ;-- objects/3
				[
		        	input [
		        		prompt "Scroll Panel Size"
		        		type "pair"
		        		detail "Enter the size of the scroll panel. Using the WWWxHHH input format."
		        	]
		        	action [
		        		alter-facet/value 'size to-pair input-value
		        	]
		        ] 	        	
   	            [
   	                action [
   	                    alter-facet/value 'with compose/deep [
                    		extra/vertical-scroll-panel: (rejoin [ (objects/1/input-values/1) "-vsp-panel" ])
                    		extra/vsp-scroller: (rejoin [ (objects/1/input-values/1) "-vsp-scroller" ])
                    		
   	                    ]
   	                ]
   	            ]
   	            [
   	                action [
   	                	alter-facet/value 'name (rejoin [ (objects/1/input-values/1) "-vsp-viewport" ])
   	                    alter-facet/value 'layout-block compose/deep [
	   	                    (to-set-word (rejoin [ (objects/1/input-values/1) "-vsp-panel" ]) ) vertical-scroll-panel with [ ; Where the action is
	   	                    		extra/vsp-scroller: (rejoin [ (objects/1/input-values/1) "-vsp-scroller" ]) ;-- (input-values/2)
	   	                    		extra/vsp-viewport-panel: (rejoin [ (objects/1/input-values/1) "-vsp-viewport" ])
   	                    	]
   	                    ]
   	                ]
   	            ]
   	            [
   	            	action [
   	            		modify-facet/value vid-code/text rejoin [ objects/1/input-values/1 "-vsp-panel" ] 
   	            			'layout-block compose [ 
   	            				below
   	            				space 2x2
            					(to-set-word (rejoin [ (objects/1/input-values/1) "-btn1" ]) ) button "After creating this panel"

            					(to-set-word (rejoin [ (objects/1/input-values/1) "-btn2" ]) ) button "Select Menu: Edit/VID Code/Prettify VID Code"

            					(to-set-word (rejoin [ (objects/1/input-values/1) "-btn3" ]) ) button "Or use: modify-scroll-panel"
            					
            					(to-set-word (rejoin [ (objects/1/input-values/1) "-btn4" ]) ) button "See comments left in the"            					
            					
            					(to-set-word (rejoin [ (objects/1/input-values/1) "-btn5" ]) ) button "on-create block in"  
            					
            					(to-set-word (rejoin [ (objects/1/input-values/1) "-btn6" ]) ) button (rejoin [ "of the: " objects/1/input-values/1 "-vsp-panel" ])
   	            			]
   	            		modify-facet/value vid-code/text rejoin [ objects/1/input-values/1 "-vsp-panel" ] 
   	            			'on-create compose [ 
   	            				comment (rejoin [ {Advanced Use: modify-scroll-panel } objects/1/input-values/1 {-vsp-panel [ b1: button "b1" b2: button "b2"]} ])
   	            			]
   	            	]
   	            ]	
   	        ]
   	    ]
	    on-wheel [ 
	        move-vertical-scroll-panel/wheel (get to-word face/extra/vertical-scroll-panel) event/picked 
	    ]

    style vsp-scroller: scroller 16x16 
    	extra [
    	    vertical-scroll-panel: "" 
    	    vsp-viewport-panel: "" 
    	    setup-style: [  ;-- objects/4
    	        [
    	            action [
    	            	alter-facet/value 'name (rejoin [ (objects/1/input-values/1) "-vsp-scroller" ])
    	                alter-facet/value 'with compose/deep [
                   			extra/vertical-scroll-panel: (rejoin [ (objects/1/input-values/1) "-vsp-panel" ]) 
    	                	extra/vsp-viewport-panel: (rejoin [ (objects/1/input-values/1) "-vsp-viewport" ])
    	                ]
    	            ]
    	        ]
    	    ]
    	]
    	on-change [
            move-vertical-scroll-panel (get to-word face/extra/vertical-scroll-panel) 
        ] 
        on-create [
        	vsp-viewport-panel-object: get to-word face/extra/vsp-viewport-panel
        	face/size: to-pair reduce [ 16 vsp-viewport-panel-object/size/y ]
        ]
        on-created [
        	vsp-viewport-panel-object: get to-word face/extra/vsp-viewport-panel
        	vertical-scroll-panel-object: get to-word face/extra/vertical-scroll-panel
            face/selected: (vsp-viewport-panel-object/size/y / vertical-scroll-panel-object/size/y )
        ]
        on-wheel [
            move-vertical-scroll-panel/wheel (get to-word face/extra/vertical-scroll-panel) event/picked
        ]
    	     
	;-- *************************************************************************************************	
	vsp-underlay1: vsp-underlay 
		with [ extra/vsp-viewport-panel: "vsp-viewport-panel1" ]
		[
			origin 3x3 
			vsp-viewport-panel1: vsp-viewport-panel 400x300
				with [
					extra/vertical-scroll-panel: "vertical-scroll-panel1"
					extra/vsp-scroller: "vsp-scroller1"
				]
		    	[ 
			        vertical-scroll-panel1: vertical-scroll-panel  with [ 
			        	extra/vsp-scroller: "vsp-scroller1" 
			        	extra/vsp-viewport-panel: "vsp-viewport-panel1"
			        ][
			        	below 
			        	b1: button "sample button"
			        ]
		 	    ]
			space 4x2	    
		    vsp-scroller1: vsp-scroller 
		    	with [ 
		    		extra/vertical-scroll-panel: "vertical-scroll-panel1" 
		    		extra/vsp-viewport-panel: "vsp-viewport-panel1"
		    	]
		]

    space 10x10
    return 
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view panel-with-vertical-scrolling-scenario-layout
]
