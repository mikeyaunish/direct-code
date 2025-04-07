Red [
	Title: "base-with-outline-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
base-with-outline-style-layout: [
    style base-with-outline: base 240.240.240 
		on-created [
			box-size: to-pair reduce [(face/size/x - 1) (face/size/y - 1)] 
			face/draw: compose/deep [
			    pen 200.200.200 line-width 1 
			    box 1x1 (box-size)
			]
		]
	style base-red: base 255.255.255	
	base-with-outline1: base-with-outline
	return
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view base-with-outline-style-layout
]