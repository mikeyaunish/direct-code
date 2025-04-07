Red [
	Title: "field-for-saved-string-with-label-inline-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
field-for-saved-string-with-label-inline-scenario-layout: [
	style label-inline: text "Label Text:" 230.230.230 font-color 0.0.0 right middle
    	extra [
            setup-style: [
                [
                    input [
                        prompt "Label Text:"
                        detail "Enter the text label for the field."
                    ]
                    action [
                        alter-facet/value 'text input-value 
                    ]
                ]
            ]    
    	]
	style field-saved: Field 80x23 
        extra [
            save-name: ""
            save-filename: copy %""
            setup-style: [
	            [
	                input [
	                    prompt "Field and Save Name"
	                    detail "Name of of the field to be created. The field data will be saved to a file named: <field-name>.data"
	                ]
	                action [
	                	comment {first check if a .data file with this name exists}
	                	if exists? to-file rejoin [ system/options/path (input-value) ".data" ][
	                		requester-results: prompt/text rejoin [ "The data file name: '" input-value ".data' already exists. Please enter a different base name for the save file (excluding the '.data' file name extension." ] 400x100
	                		while [ exists? rejoin [ system/options/path requester-results ".data" ]] [
	                			requester-results: prompt/text rejoin [ "The data file name: '" requester-results ".data' already exists. Please enter a different base name for the save file (excluding the '.data' file name extension." ] 400x100
	                		]
	                		input-value: copy requester-results
	                	]
	                	either none? input-value [
	                		false
	                	][
	                		alter-facet/value 'with compose/deep [ extra/save-name: (input-value) ]	
	                		alter-facet/value 'name input-value
	                	]
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
    space 2x2
	label-inline1: label-inline "Age:"
	age-field: field-saved with [extra/save-name: "age-field"]
	space 10x10
	
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view field-for-saved-string-with-label-inline-scenario-layout
]
