Red [
	Title: "base-with-drawing-and-label-above-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
base-with-drawing-and-label-above-scenario-layout: [
	style attached-text: text extra [
	    setup-style: [
	        [
	            input [
	                prompt "Text label" 
	                detail "The text that you want displayed above the drawing."
	            ] 
	            action [
	                alter-facet/value 'text input-value
	            ]
	        ]
	    ]
	]
	style base-drawing: base 0.0.0.255 font-color 36.12.189.0 
		extra [
		    attached-object: "" 
		    attached-offset: 0x0 
		    setup-style: [
		        [
		            input [
		                prompt "Draw Code" 
		                detail "Supply the draw code you want to see"
		            ] 
		            action [
		                alter-facet/value 'with compose/deep [
		                	extra/attached-object: (to-lit-word objects/1/object-name )
		                	extra/attached-offset: 0x25
		                ]
		                alter-facet/value 'draw compose/deep [
		                	(load input-value)
		                ]
		            ]
		        ]
		    ]
		] 
		on-create [
			face/offset: (get in get face/extra/attached-object 'offset ) + face/extra/attached-offset
		]
	attached-text1: attached-text "Drawing below" 80x25 no-wrap
	base-drawing1: base-drawing 
		draw [
			circle 10x10 10
		] 
		with [
		    extra/attached-object: 'attached-text1 
		    extra/attached-offset: 0x25
		]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view base-with-drawing-and-label-above-scenario-layout
]
