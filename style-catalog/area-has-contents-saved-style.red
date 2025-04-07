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
			]
		] 
		on-create [
			if exists? face/extra/save-filename [
				face/text: read face/extra/save-filename
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