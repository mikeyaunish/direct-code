Red [
	Title: "text-list-with-search-field-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
text-list-with-search-field-scenario-layout: [
	style text-list-data-supplier: text-list 124x140 
		data []
		on-dbl-click [
			picker-face: get to-word face/extra/picker-face
			do-actor picker-face none 'enter
		] 
		on-key-up [
			if event/key = #"^[" [
				picker-face: get to-word face/extra/picker-face
				do-actor picker-face event 'key-up
			]
		]
		on-change [
			picker-face: get to-word face/extra/picker-face
			picker-face/text: copy pick face/data face/selected 
		]
		extra [
		    picker-face: "" 
		    last-selected: 0 
		    setup-style: [
		        [
		            input [
		                prompt "text-list name" 
		                detail "The name of the text-list object."
		            ] 
		            action [
		                alter-facet/value 'name input-value
		            ]
		        ]
		    ]
		]

	style data-picker-style: field-data-picker 101x24 focus
		extra [
			data-face: none
			last-selected: 0
		    setup-style: [
		        [
		            action [
	                	modify-facet/value vid-code/text (objects/1/object-name) 'with compose/deep [
	                		extra/last-selected: 0
	                		extra/picker-face: ( object-name )
	                	]
		                alter-facet/value 'with compose/deep [
		                	extra/data-face: (to-word objects/1/object-name )
		                ]
		            ]
		        ]
		    ]
		] 

	space 10x1
	text-list-data-supplier1: text-list-data-supplier 
		data [ "apple" "able" "baker" "barker" "barkeep" "canner" "container" "detail" "description" "easy" "easter" "flood" "flea"]
		with [
			extra/last-selected: 0
			extra/picker-face: "field-data-picker1" 
		]
	return 	
	search-icon: base 23x23 220.220.220 
		draw [
			pen 0.0.0
			line-width 2 
			circle 9x9 6 
			line 14x14 21x21
		]
	space 0x0
	field-data-picker1: data-picker-style 		
		with [ 
			extra/data-face: text-list-data-supplier1
		]
		on-enter [
			print ["Selection made =" mold face/text]
		]
	space 10x10
	return 
		
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view text-list-with-search-field-scenario-layout
]
