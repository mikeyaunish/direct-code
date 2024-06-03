Red [
	Title: "calendar-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
calendar-root-style-layout: [
    style calendar-root: calendar extra [
	    setup-style: [
	        [
	            input [
	                prompt "Highlighted Date"
	                type "date" 
	                detail "Enter the date that will be highlighted on the calendar"
	            ] 
	            action [
	                alter-facet/value 'date to-valid date! input-value
	            ]
	        ]
	    ]
	]
	calendar-root1: calendar-root 10-Aug-1920
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view calendar-root-style-layout
]