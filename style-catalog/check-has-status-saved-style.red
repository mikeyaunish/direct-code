Red [
	Title: "check-has-status-saved-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
check-has-status-saved-style-layout: [
	style check-has-status-saved: check  
        extra [
            save-filename: %""
            setup-style: [
                [
                    input [
                        prompt "Check box VID object name"
                    	detail {Name of of the VID check object to be created."}
                    	validator "object-name"
                    ]
                    action [
                    	alter-facet/value 'name input-value
                    ]
                ]
				[
                    input [
                        prompt "Check text"
                        detail "Text that will appear next to the check object created."
                    ]
                    action [
						full-filename: find-unused-filename rejoin [
							system/options/path 
							rejoin ["vid-" input-values/1 "-check.data"]
						] 
						alter-facet/value 'with compose/deep [extra/save-filename: (second split-path full-filename)]                         
						alter-facet/value 'text input-value
                    ]                    
                ]            	
            ]    
        ] 
        on-create [
			if exists? face/extra/save-filename [
				face/data: load face/extra/save-filename
			]			
        ] 
        on-change [
            if face/extra/save-filename <> %"" [
                save/all face/extra/save-filename face/data
            ]
        ]
	happy: check-has-status-saved "Happy" with [extra/save-filename: %vid-happy-check.data]
	floppy: check-has-status-saved "Floppy?" with [extra/save-filename: %vid-floppy-check.data]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view field-saved-layout
]