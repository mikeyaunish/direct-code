Red [
	Title: "base-has-corners-rounded-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
base-has-corners-rounded-style-layout: [
    style base-has-corners-rounded: base "base2" font-color 255.255.255 
	    on-create [
	        clip: 3
	        width: face/size/x
	        height: face/size/y
	        clipped-x: width - clip
	        clipped-y: height - clip
	        nw-y: 0
	        face/draw: compose/deep [ 
	            pen snow line-width 2 
                triangle 0x0 (to-pair reduce [ clip 0 ]) (to-pair reduce [ 0 clip ])
                triangle (to-pair reduce [ width 0 ]) (to-pair reduce [ width clip ])  (to-pair reduce [ clipped-x 0 ])
                triangle (to-pair reduce [ 0 height ]) (to-pair reduce [ clip height ])  (to-pair reduce [ 0 clipped-y ])
                triangle (to-pair reduce [ width height ]) (to-pair reduce [ clipped-x height ])  (to-pair reduce [ width clipped-y ])
            ]
        ]

]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view base-has-corners-rounded-style-layout
]