Red [
	Title: "label-inline-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
label-inline-style-layout: [
    style label-inline: text "Label Text:" 230.230.230 font-color 0.0.0 right middle
    	extra [
            setup-style: [
                [
                    input [
                        prompt "Label Text:"
                        detail "Enter the text that the label will display"
                    ]
                    action [
                        alter-facet/value 'text input-value 
                    ]
                ]
            ]    
    	]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view label-inline-style-layout
]