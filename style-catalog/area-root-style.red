Red [
	Title: "area-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
area-root-style-layout: [
    style area-root: area extra [
	    setup-style: [
	        [
	            input [
	                prompt "Size" 
	                detail "The size of the area. Enter the size in WWxHH pair format. IE: 200x100 "
	            ] 
	            action [
	                alter-facet/value 'size to-pair input-value
	            ]
	        ]
	        [
	        	input [
	        		prompt "Disable Tabbing?"
	        		type "check"
	        		detail "Pressing the tab key WON'T move you to the next widget but WILL insert a tab into the text area."
	        	]
	        	action [
	        		if input-value [
	        			alter-facet/value 'on-create [set-flag/toggle face 'focusable]	
	        		]
	        	]
	        	
	        ]
	    ]
	]
	area-root1: area-root 100x50 on-create [set-flag/toggle face 'focusable]
	area-root2: area-root 400x40
	field1: field "field1"
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view area-root-style-layout
]