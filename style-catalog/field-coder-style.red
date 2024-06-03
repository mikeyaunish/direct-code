Red [
	Title: "field-coder-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
field-coder-style-layout: [
    style field-coder: Field 900x26 0.9.0.0 bold font-name "Consolas" font-size 13 font-color 7.217.18.0 
        extra [
            save-name: "" 
            save-filename: copy  %"" 
            last-file-data: copy "" 
            has-focus?: false 
            setup-style: [
                [
                    input [
                        prompt "Name used for field and 'save name'" 
                        detail "Name of of the field to be created. Which is also the file name used to save the contents of the field. The saved file name has the extension: '.data'"
                    ] 
                    action [
                        alter-facet/value 'name input-value
                        alter-facet/value 'with compose/deep [extra/save-name: (input-value)]
                    ]
                ]
            ]
        ] 
        on-create [
            if face/extra/save-name <> "" [
                face/extra/save-filename: to-file rejoin [ system/options/path face/extra/save-name ".data"]
                if exists? face/extra/save-filename [
                    face/extra/last-file-data: face/text: read face/extra/save-filename
                ]
            ]
        ] 
        on-change [
            if face/extra/save-name <> "" [
                write face/extra/save-filename face/text     
            ]
        ]
        on-enter [
            do face/text 
        ]
        on-key [
            if event/key = #"^K" [
                do face/text
            ]
            if event/key = #"^O" [
                editor face/extra/save-filename
            ]
            if event/key = #"^R" [
                face/text: read face/extra/save-filename
            ]
        ]
        rate 00:00:00.25 
        on-time [
            if not face/extra/has-focus? [
                current-data: read face/extra/save-filename
                if current-data <> face/text [
                    face/text: current-data
                    do face/text 
                ]
            ]
        ] 
        on-focus [face/extra/has-focus?: true] 
        on-unfocus [
            write face/extra/save-filename face/text
            face/extra/has-focus?: false
        ]
    
    
    
    f1: field-coder with [extra/save-name: "f1"]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view field-coder-style-layout
]