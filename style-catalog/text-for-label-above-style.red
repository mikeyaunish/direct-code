Red [
	Title: "text-for-label-above-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
text-for-label-above-style-layout: [
    style text-for-label-above: text "Label text" font-color 0.0.0 font-size 12
        extra [
            setup-style: [
                [
                    input [
                        prompt "Label text"
                        detail "Enter the text that you want the label to display"
                    ]
                    action [
                        alter-facet/value 'text input-value 
                    ]
                ]
            ]    
    	]
	text-for-label-above1: text-for-label-above "Label Above"
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view text-for-label-above-style-layout
]