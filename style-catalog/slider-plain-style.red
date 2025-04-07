Red [
	Title: "slider-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
slider-plain-style-layout: [
    style slider-plain: slider extra [
	    setup-style: [
	        [
	            input [
	                prompt "Slider Position in percentage" 
	                detail "Enter a percent value for where you want the slider to be. IE: 25% or .25"
	            ] 
	            action [
	                alter-facet/value 'percent to-percent input-value
	            ]
	        ]
	    ]
	]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view slider-plain-style-layout
]