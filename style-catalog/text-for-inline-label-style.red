Red [
	Title: "text-for-inline-label-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
text-for-inline-label-style-layout: [
    style text-for-inline-label: text "Label Text:" 230.230.230 font-color 0.0.0 right middle 
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
	text-for-inline-label1: text-for-inline-label "Address:"
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view text-for-inline-label-style-layout
]