Red [
	Title: "field-has-contents-saved-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
field-has-contents-saved-style-layout: [
	style field-has-contents-saved: Field 80x23 
        extra [
            save-filename: %""
            setup-style: [
                [
                    input [
                        prompt "Field name"
                        detail "Name of of the VID field object to be created."
                    ]
                    action [
                        alter-facet/value 'name input-value
                    ]
                ][
                    action [
						full-filename: find-unused-filename rejoin [
							system/options/path 
							rejoin ["vid-" input-values/1 "-field.text"]
						] 
						alter-facet/value 'with compose/deep [extra/save-filename: (second split-path full-filename)]                         
                    ]
                ]
            ]    
        ] 
		on-create [
			if exists? face/extra/save-filename [
				face/text: read face/extra/save-filename
			]
		] 
		on-change [
			if face/extra/save-filename <> %"" [
				write face/extra/save-filename face/text
			]
		]
	fld1: field-has-contents-saved 125x23 with [extra/save-filename: %vid-fld1-field.text]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view field-has-contents-saved-layout
]