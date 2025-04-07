Red [
	Title: "toggle-has-status-saved-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
toggle-has-status-saved-style-layout: [
	style toggle-has-status-saved: toggle "toggle1"	
		extra [
		    save-filename: %"" 
		    setup-style: [
                [
                    input [
                        prompt "Toggle object name"
                    	detail {Name of of the VID toggle object to be created."}
                    	validator "object-name"
                    ]
                    action [
                    	alter-facet/value 'name input-value
                    ]
                ] 
				[
                    input [
                        prompt "Toggle text"
                        detail "Text that will appear on the toggle object created."
                    ]
                    action [
						full-filename: find-unused-filename rejoin [
							system/options/path 
							rejoin ["vid-" input-values/1 "-toggle.data"]
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
	
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view toggle-has-status-saved-style-layout
]