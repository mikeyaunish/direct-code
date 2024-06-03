Red [
	Title: "area-coder-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
area-coder-style-layout: [
    style area-coder: area 745x200 left  black green bold font-size 13 font-name "Courier New" focus
        extra [
            save-name: ""
            save-filename: copy %""
            has-focus?: false 
            setup-style: [
                [
                    input [
                        prompt "Area name"
                        detail "Name of of the area to be created."
                    ]
                    action [
                        alter-facet/value 'with compose/deep [ extra/save-name: (input-value) ]
                        alter-facet/value 'name input-value
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
            face/flags: none
        ] 
        on-change [
            if face/extra/save-name <> "" [
                write face/extra/save-filename face/text     
            ]
        ]
        on-key [
            if event/key = #"^K" [
                do face/text
            ]
            if event/key = #"^O" [
                editor face/extra/save-filename
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
	style button-plain: button "button1"
	style run-button: button-plain "Run [ Ctrl + K ]" on-click [do a2/text]        
    
    a2: area-coder with [extra/save-name: "a2"]
	space 2x2
    return
	button-plain11: run-button
	
    button-plain1: button-plain "Open [ Ctrl + O ]" on-click [editor a2/extra/save-filename]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view area-coder-style-layout
]