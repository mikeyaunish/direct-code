Red [
	Title: "text-list-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
text-list-plain-style-layout: [
    style text-list-plain: text-list
		extra [
		    setup-style: [
		        [
		            action [
		            	alter-facet/value 'data ["apple" "banana" "cherry" "dandelion"]
		                alter-facet/value 'select 2
		            ]
		        ]
		    ]
		]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view text-list-plain-style-layout
]