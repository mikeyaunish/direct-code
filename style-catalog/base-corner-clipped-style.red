Red [
	Title: "base-corner-clipped-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
base-corner-clipped-style-layout: [
    style base-corner-clipped: base "base2" font-color 255.255.255 
	    on-create [
	        clip: 3
	        width: face/size/x
	        height: face/size/y
	        clipped-x: width - clip
	        clipped-y: height - clip
	        nw-y: 0
	        face/draw: compose/deep [ 
	            pen snow line-width 2 
                triangle 0x0 (to-pair reduce [ clip 0 ]) (to-pair reduce [ 0 clip ])
                triangle (to-pair reduce [ width 0 ]) (to-pair reduce [ width clip ])  (to-pair reduce [ clipped-x 0 ])
                triangle (to-pair reduce [ 0 height ]) (to-pair reduce [ clip height ])  (to-pair reduce [ 0 clipped-y ])
                triangle (to-pair reduce [ width height ]) (to-pair reduce [ clipped-x height ])  (to-pair reduce [ width clipped-y ])
            ]
        ]
	style button-plain: button "button1"
	style field-coder: Field 900x26 0.9.0.0 bold font-name "Consolas" font-size 12 font-color 7.217.18.0 
        extra [
            save-name: ""
            save-filename: copy %""
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
        on-enter [
            do face/text 
        ]
        on-key [
            if event/key = #"^K" [
                do face/text
            ]
            if event/key = #"^E" [
                editor face/extra/save-filename
            ]
            if event/key = #"^R" [
                face/text: read face/extra/save-filename
            ]
        ]
	style cfs-run-button: button "Run" 42x20
	style cfs-edit-button: button "Edit" 42x20
	style cfs-reload-button: button "Reload" 50x20
	style cfs-reload-and-run-button: button "Reload and Run" 100x20
    base-corner-clipped1: base-corner-clipped 206x288
    base-corner-clipped2: base-corner-clipped 239x164 199.64.30.0
    button-plain1: button-plain "What "
	return
    space 1x1
    c1: field-coder with [extra/save-name: "c1"] 
    return 
	cfs-run-button1: cfs-run-button on-click [do c1/text]
	cfs-edit-button1: cfs-edit-button on-click [editor c1/extra/save-filename]
	cfs-reload-button1: cfs-reload-button on-click [c1/text: read c1/extra/save-filename]
	cfs-reload-and-run-button1: cfs-reload-and-run-button on-click [do c1/text: read c1/extra/save-filename]
	space 10x10
	return 
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view base-corner-clipped-style-layout
]