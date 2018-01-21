Red [
	Title: "matrix.red"
]

dc-matrix: object [
    ; ********** future triggers for [face-type / field-name] *************   
    button: object [  ; button type object
        offset: 'move-object
        ;size:
        ;text:
    ]
    field: object [  ; button type object
        offset: 'move-object
        ;size:
        ;text:
    ]
    base: object [  ; button type object
        offset: 'move-object
        ;size:
        ;text:
    ]
    
    last-active-action-object-name: none
    activate: func [ 
        action-object-name [word!] 
        /local action-obj activate-func
    ][
        last-active-action-object-name: action-object-name
        action-obj: dc-matrix/:action-object-name
    	activate-func: get in action-obj 'activate
        do (bind body-of :activate-func dc-ctx)        
    ]
    
    deactivate: func [
        /local action-obj deactivate-func
    ][
        if dc-matrix/last-active-action-object-name [
            action-obj: dc-matrix/:last-active-action-object-name
            deactivate-func: get in action-obj 'deactivate 
            do (bind body-of :deactivate-func dc-ctx)
            last-active-action-object-name: none
        ]
    ]
    
	; ********** action objects  ***********
	move-object: object [
        activate: does [
            if --obj-selected [ 
                --move-pointer/offset: --obj-selected/offset + ( divide (--obj-selected/size - --move-pointer/size ) 2 )
                react/link :link-offset [ --obj-selected --move-pointer]
            ]                
        ]
        deactivate: does [
            react/unlink :link-offset 'all
            --move-pointer/offset: --move-pointer-origin
        ]
        update-source-code: function[ obj-name ] [
            fld-name: "offset"
        	cur-val:  reduce to-path reduce [ to-word obj-name to-word fld-name ]
        	set-obj-string: rejoin [ obj-name ":" ] 
        	fnd-at: index? find ( split-block: multi-split vid-code/text [ "^/" "^-" " " ] ) set-obj-string
        	two-words-back: pick split-block ( fnd-at - 2  )
        	cur-val: cur-val + 1x1 ; make up for real vs. visual placement of objects
        	either ( two-words-back = "at" ) [      ;-- Already an existing 'at' position specified
        		now-at: pick split-block ( fnd-at - 1)
        		either (string-is-pair? now-at)[          ;-- A valid pair exists, just change it
            		replace vid-code/text rejoin [ 
            			"at " now-at " " set-obj-string 
            		]	 
            		rejoin [
            			"at " cur-val " " set-obj-string
            		]
            	][                                  ;-- The 'at' position is not a pair (
            	    if (string-is-word? now-at) [
            	        set-word-string: rejoin [ now-at ":"]
            	        if (find setup-code/text set-word-string ) [
            	            src-code: multi-split setup-code/text [ "^^/" "^-" "^/" " " ]
            	            src-code: form src-code
            	            now-val: string-select src-code set-word-string
                    		replace setup-code/text rejoin [ 
                    			set-word-string " " now-val
                    		]	 
                    		rejoin [
                    			set-word-string " " cur-val
                    		]
            	        ]
            	    ]
            	]
        	][                                      ;-- No 'at' position exists yet, one will be created
        		replace vid-code/text set-obj-string rejoin [
        			"at " cur-val " " set-obj-string			
        		]	
        	]
        ]
    ]
    move-custom: object []
]


