Red [
	Title: "toggle-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
toggle-plain-style-layout: [
    style toggle-plain: toggle extra [
	    setup-style: [
	        [
	            input [
	                prompt "Toggle Text label" 
	                detail "The text that will display on the toggle."
	            ] 
	            action [
	                alter-facet/value 'text input-value
	                alter-facet/value 'on-change compose/deep [
	                	print [ "Toggle is" face/data ]
	                ]
	            ]
	        ]
	    ]
	]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view toggle-plain-style-layout
]