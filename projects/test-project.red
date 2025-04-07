Red [
	Title: "test-project.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
test-project-layout: [
	h1-1: h1 "Test Project"
	return
	text1: text {This is a test project where you can play with all of the features of Direct Code} font-size 11
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view test-project-layout
]