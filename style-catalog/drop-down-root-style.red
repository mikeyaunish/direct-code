Red [
	Title: "drop-down-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
drop-down-root-style-layout: [
    style drop-down-root: drop-down  
		extra [
		    setup-style: [
		        [
		            action [
		                alter-facet/value 'data ["one" "two" "three" "four"]
		            ]
		        ]
		    ]
	] 
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view drop-down-root-style-layout
]