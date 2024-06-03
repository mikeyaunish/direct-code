Red [
	Title: "button-info-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
button-info-style-layout: [
	style button-info: base 17x18 info-icon
        extra [ 
            now-over?: 0 
            message: ""
            box: 0
            setup-style: [
                [   ;-- input-values/1
                    input [
                        prompt "Popup text"
                        detail "Enter the text that you want displayed when the mouse is rolled over the info-icon"
                    ]
                ][  ;-- input-values/2
                    input [
                        prompt "Show info in box?"
                        type "check"
                        detail "By default info will display in a 'line'. Longer text strings will display better in a 'box'."
                    ]
                ][
                    action [
                        box-state: either input-values/2 [ 1 ] [ 0 ]
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
                    box: either face/extra/box = 0 [
                        false    
                    ][
                        true
                    ]
                    popup-help/offset/:box face/extra/message (face/parent/offset + face/offset + event/offset + 20x20) 
                ]
            ]
        ]
        with [
            extra/message: ""
        ]
	
    button-info1: button-info with [
    extra/message: "Hello there how are you"
]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view button-info-style-layout
]