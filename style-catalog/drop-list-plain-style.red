Red [
	Title: "drop-list-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
drop-list-plain-style-layout: [
    style drop-list-plain: drop-list  
		extra [
		    setup-style: [
		        [
		            action [
		                alter-facet/value 'data ["one" "two" "three" "four"]
		                alter-facet/value 'select 2
		            ]
		        ]
		    ]
	] 
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view drop-list-plain-style-layout
]