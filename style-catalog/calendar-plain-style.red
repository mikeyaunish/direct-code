Red [
	Title: "calendar-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
calendar-plain-style-layout: [
    style calendar-plain: calendar extra [
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
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view calendar-plain-style-layout
]