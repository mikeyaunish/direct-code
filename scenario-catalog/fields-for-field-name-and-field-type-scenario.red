Red [
	Title: "fields-for-field-name-and-field-type-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
fields-for-field-name-and-field-type-scenario-layout: [
	style label-inline: text "Label Text:" 230.230.230 font-color 0.0.0 right middle
	style field-has-contents-saved: Field 80x23 
        extra [
            save-name: ""
            save-filename: ""
            setup-style: [
                [
                    action [
                    		alter-facet/value 'with compose/deep [ extra/save-name: (object-name) ]	
                    ]
                ]
            ]    
        ] 
        on-create [
            if face/extra/save-name <> "" [
                face/extra/save-filename: to-file rejoin [ system/options/path face/extra/save-name "-field-obj.data"]
                if exists? face/extra/save-filename [
                    face/text: read face/extra/save-filename
                ]
            ]
        ]  
        on-change [
            if face/extra/save-name <> "" [
                write face/extra/save-filename face/text     
            ]
        ]
	style drop-down-has-selection-saved: drop-down 
	    on-create [
	        if face/extra/save-name <> "" [
				filename: to-file rejoin [ system/options/path face/extra/save-name "-drop-down-obj.data"]
	            if exists? filename [
	                face/selected: load filename
	            ]	            
	        ]
	    ] extra [
	    	save-name: "" 
		    setup-style: [
		        [
		            action [
		                alter-facet/value 'with compose [ extra/save-name: (object-name)]
		            ]
		        ]
		    ]
		] 
		data ["string!" "integer!" "logic!" "block!" "float!" "file!" ] 
	    on-change [
	        if face/extra/save-name <> "" [
	            save/all to-file rejoin [ system/options/path face/extra/save-name "-drop-down-obj.data"] face/data     
	            save/all to-file rejoin [ system/options/path face/extra/save-name "-drop-down-selected.data"] face/selected
	        ]
	    ]
	space 1x8
	label-inline1: label-inline "Field Name:"
	field-name1: field-has-contents-saved with [extra/save-name: "field-name1"]
	space 8x8
	label-inline2: label-inline "Field Type:"
	space 1x8
	drop-down-has-selection-saved1: drop-down-has-selection-saved with [extra/save-name: "drop-down-has-selection-saved1"]
	space 8x8
	return
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view fields-for-field-name-and-field-type-scenario-layout
]
