Red [
	Title: "drop-down-does-code-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
drop-down-does-code-style-layout: [
    style drop-down-does-code: drop-down
		on-create [
			do-selected: function [face] [
				do pick face/data (face/selected * 2 )
			]
		] 
		on-change [
			do-selected face
		]
	 
		data [
			"Hello World" [
				print "Test Running"
			]
			"Test #2" [
				print "Test #2"
			]
		] 
		select 1
	drop-down-does-code1: drop-down-does-code
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view drop-down-does-code-style-layout
]