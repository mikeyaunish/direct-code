Red [
	Title: "field-with-request-file-button.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
field-with-request-file-button-scenario-layout: [
	style label-inline: text "Label Text:" 230.230.230 font-color 0.0.0 right middle
	style field-has-contents-saved: Field 80x23 
        extra [
            save-name: ""
            save-filename: ""
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
	label-inline1: label-inline "File Name:"
	filename-field: field-has-contents-saved 360x24 with [extra/save-name: "filename-field"]
	button1: button "..." 30x23 on-click [
		current-path: does [ first split-path current-file ]
		if (rf: request-file/title/file "Save Image of GUI as a '.png' file" current-path) [
	    	filename-field/text: to-string rf
		]
	]
	space 10x10
	return
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view field-with-request-file-button-layout
]
