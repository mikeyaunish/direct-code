Red [
	Title: "area-has-contents-saved-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
area-has-contents-saved-style-layout: [
	style area-has-contents-saved: area 
		extra [
			save-filename: %"" 
			setup-style: [
				[
					input [
						prompt "Area name" 
						detail "Name of of the area to be created."
						validator "object-name"
					] 
					action [
						alter-facet/value 'name input-value
						full-filename: find-unused-filename rejoin [
							system/options/path rejoin 
							["vid-" input-value "-area.text"]
						] 
						alter-facet/value 'with compose/deep [extra/save-filename: (second split-path full-filename)] 
						
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
		        		either input-value [
		        			alter-facet/value 
		        				'on-create [
									if exists? face/extra/save-filename [
										face/text: read face/extra/save-filename
									]
		        					set-flag/toggle face 'focusable
		        				]	
		        		][
		        			alter-facet/value 
		        				'on-create [
									if exists? face/extra/save-filename [
										face/text: read face/extra/save-filename
									]
		        				]	
		        		]
		        	]
		        ]				
			]
		] 
		on-change [
			if face/extra/save-filename <> %"" [
				write face/extra/save-filename face/text
			]
		]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view area-has-contents-saved-style-layout
]