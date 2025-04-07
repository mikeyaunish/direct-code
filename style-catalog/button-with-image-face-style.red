Red [
	Title: "button-with-image-face-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
button-with-image-face-style-layout: [
	style button-with-image-face: button  
		extra [
			normal-image: ""
			hilight-image: ""
		    setup-style: [
		        [
		            input [
		                prompt "Image Filename" 
		                type "file" 
		                detail "The filename of the image you want to use"
		            ] 
		            action [
		                alter-facet/value 'file to-valid-file input-value
		                x: load to-file input-value
		                alter-facet/value 'size x/size
		            ]
		        ]
		    ]
		]
		on-created [
			if not none? face/image [
				face/extra/normal-image: face/image
				face/extra/hilight-image: get-hilight-image face/image
			]
		]
	    on-over [ 
			face/image: either event/away? [ 
				face/extra/normal-image
			][ 
				face/extra/hilight-image 
			]
		]	    
	button-with-image-face1: button-with-image-face 22x22 %/E/red/direct-code/style-catalog/zero-icon-image-large.png
	button-with-image-face2: button-with-image-face 22x22 %/E/red/direct-code/style-catalog/zero-icon-image-large.png
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view button-with-image-face-style-layout
]