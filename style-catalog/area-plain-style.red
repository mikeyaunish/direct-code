Red [
	Title: "area-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
area-plain-style-layout: [
    style area-plain: area extra [
	    setup-style: [
			[
				input [
					prompt "Area name" 
					detail "Name of of the area to be created."
					validator "object-name"
				] 
			]	    	
	        [
	            input [
	                prompt "Size" 
	                type "pair"
	                detail "The size of the area. Enter the size in WWxHH pair format. IE: 200x100 "
	            ] 
	            action [
	                alter-facet/value 'size to-pair input-value
	            ]
	        ]
	        [
	        	input [
	        		prompt "Disable Tabbing Between Objects?"
	        		type "check"
	        		detail "When tabbing is disabled pressing the tab key WON'T move you to the next GUI widget but WILL insert a tab into the text area itself."
	        	]
	        	action [
	        		if input-value [
	        			alter-facet/value 'on-create [set-flag/toggle face 'focusable]	
	        		]
	        	]
	        	
	        ]
	    ]
	]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view area-plain-style-layout
]