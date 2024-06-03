Red [
	Title: "field-saved.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
field-saved-style-layout: [
	style field-saved: Field 80x23 
        extra [
            save-name: ""
            save-filename: copy %""
            setup-style: [
                [
                    input [
                        prompt "Field name"
                        detail "Name of of the field to be created."
                    ]
                    action [
                        alter-facet/value 'name input-value
                    ]
                ][
                    input [
                        prompt "Save Name"
                        detail "The 'Save Name' is used as the filename that holds the contents of this field. IE: <save-name>.data. Make sure to provide a save name that isn't being used."
                    ]
                    action [
                    	if exists? to-file rejoin [ system/options/path (input-value) ".data" ][
                    		requester-results: prompt/text/size rejoin [ "The data file name: '" input-value ".data' already exists. Please enter a different base name for the save file (excluding the '.data' file name extension." ] 400x100
                    		while [ exists? rejoin [ system/options/path requester-results ".data" ]] [
                    			requester-results: prompt/text/size rejoin [ "The data file name: '" requester-results ".data' already exists. Please enter a different base name for the save file (excluding the '.data' file name extension." ] 400x100
                    		]
                    		input-value: copy requester-results
                    	]
                    	either none? input-value [
                    		false
                    	][
                    		alter-facet/value 'with compose/deep [ extra/save-name: (input-value) ]	
                    	]
                        
                    ]
                ]
            ]    
        ] 
        on-create [
            if face/extra/save-name <> "" [
                face/extra/save-filename: to-file rejoin [ system/options/path face/extra/save-name ".data"]
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
	f1: field-saved with [extra/save-name: "f1"]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view field-saved-layout
]