Red [
	Title: "progress-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [
]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
progress-root-style-layout: [ 
    style progress-root: progress extra [
	    setup-style: [
	        [
	            input [
	                prompt "Percent setting" 
	                detail "Enter a percent value for where you want the progress bar to be. IE: 25% or .25"
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
	view progress-root-style-layout
]