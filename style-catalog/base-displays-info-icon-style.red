Red [
	Title: "base-displays-info-icon-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
base-displays-info-icon-style-layout: [
	style base-displays-info-icon: base 17x18 info-icon
        extra [ 
            now-over?: 0 
            message: ""
            box: 0
            setup-style: [
                [ 
                    input [
                        prompt "Popup text"
                        detail "Enter the text that you want displayed when the mouse is rolled over the info-icon"
                    ]
                ][ 
                    input [
                        prompt "Show info in box?"
                        type "check"
                        ;-- validator "check"
                        detail "By default info will display in a 'line'. Longer text strings will display better in a 'box'."
                    ]
                ][
                    action [
                    	print [ "input-values =============================================== " mold input-values ]
                        box-state: either input-values/2 [ #(true) ] [ #(false) ]
                        alter-facet/value 'with compose/deep [ 
                            extra/box: (box-state)
                            extra/message: (input-values/1)
                        ]  
                    ]
                ]
            ]                
        ] 
        on-over [
            either event/away? [
                face/extra/now-over?: 0 
                face/image/rgb: complement face/image/rgb 
                show face 
                popup-help/close ""
            ][
                if face/extra/now-over? = 0 [
                    face/image/rgb: complement face/image/rgb 
                    show face 
                    face/extra/now-over?: 1
					box: face/extra/box 
                    popup-help/offset/:box face/extra/message (face/parent/offset + face/offset + event/offset + 20x20) 
                ]
            ]
        ]
	base-displays-info-icon1: base-displays-info-icon with [
	    extra/box: 0 
	    extra/message: "Hello there"
	]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view base-displays-info-icon-style-layout
]