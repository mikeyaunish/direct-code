Red [
	Title: "image-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
image-root-style-layout: [
    style image-root: image extra [
	    setup-style: [
	        [
	            input [
	                prompt "Image file" 
	                type "file"
	                detail "Select the image to display"
	            ] 
	            action [
	                alter-facet/value 'file to-valid-file input-value
	            ]
	        ]
	    ]
	]
	image-root1: image-root %/E/red/direct-code/images/refresh-icon.png
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view image-root-style-layout
]