Red [
	Title: "drop-down-has-selection-saved-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
drop-down-has-selection-saved-style-layout: [
    style drop-down-has-selection-saved: drop-down 
	    extra [
	    	save-filename: %"" 
		    setup-style: [
		        [
		            input [
		                prompt "Drop down object name" 
		                detail "The name given to the object created."
		                validator "object-name"
		            ] 
		            action [
		                alter-facet/value 'name input-value
		            ]
		        ]		    	
		        [
		            input [
		                prompt "drop-down data:" 
		                detail "Enter the data you want to display in the drop-down, separate entries with a comma."
		            ] 
		        ]
		        [
		            action [
		            	basename: either input-values/1 [ input-values/1 ][ object-name ]
						full-filename: find-unused-filename rejoin [
							system/options/path rejoin 
							["vid-" basename "-drop-down.data"]
						] 
						if input-values/2 [
							alter-facet/value 'data (split input-values/2 "," )	
						]
						alter-facet/value 'with compose/deep [extra/save-filename: (second split-path full-filename)] 		            	
		            ]
		        ]
		    ]
		]
	    on-create [
			if exists? face/extra/save-filename [
				face/selected: load face/extra/save-filename
			]
	    ] 
	   
	    on-change [
			if face/extra/save-filename <> %"" [
				save/all face/extra/save-filename face/selected 
			]	    	

	    ]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view drop-down-has-selection-saved-style-layout
]