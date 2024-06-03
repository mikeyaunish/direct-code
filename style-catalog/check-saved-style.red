Red [
	Title: "check-saved-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
check-saved-style-layout: [
	style check-saved: check  
        extra [
            save-name: ""
            save-filename: copy %""
            setup-style: [
				[
                    input [
                        prompt "Check text"
                        detail "Text that will appear next to the check object created."
                    ]
                    action [
                        alter-facet/value 'text input-value
                    ]
                ]            	
                [
                    input [
                        prompt "Check name"
                        detail "Name of of the check to be created."
                    ]
                    action [
                        alter-facet/value 'name input-value
                    ]
                ][
                    input [
                        prompt "Save Name"
                        detail "The 'Save Name' is used as the filename that holds the contents of this field. IE: <save-name>.data"
                    ]
                    action [
                        alter-facet/value 'with compose/deep [ extra/save-name: (input-value) ]
                    ]
                ]
            ]    
        ] 
        on-create [
            if face/extra/save-name <> "" [
                face/extra/save-filename: to-file rejoin [ system/options/path face/extra/save-name ".data"]
                if exists? face/extra/save-filename [
                    face/data: either (load face/extra/save-filename) = 'false [ false ] [ true ]
                ]
            ]
        ] 
        on-change [
            if face/extra/save-name <> "" [
                save face/extra/save-filename face/data
            ]
        ]
    
    
    
    a: check-saved "a" with [extra/save-name: "a"]
    b: check-saved "b" with [extra/save-name: "b"]
	return
    c: check-saved "c" with [extra/save-name: "c"]
    d: check-saved "Helpful or NOT" with [extra/save-name: "d"]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view field-saved-layout
]