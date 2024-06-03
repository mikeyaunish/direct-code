Red [
	Title: "text-list-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [
]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
text-list-root-style-layout: [ 
    style text-list-root: text-list data ["one" "two" "three" "four"] select 2
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view text-list-root-style-layout
]