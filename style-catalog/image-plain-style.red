Red [
	Title: "image-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
image-plain-style-layout: [
    style image-plain: image extra [
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
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view image-plain-style-layout
]