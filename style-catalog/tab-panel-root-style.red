Red [
	Title: "tab-panel-root-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [
]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
tab-panel-root-style-layout: [ 
    style tab-panel-root: tab-panel "tab-panel1" ["Tab-A" [tab-a-btn1: button "tab-A-btn1"] "Tab-B" [tab-b-btn1: button "tab-B-btn1"]]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view tab-panel-root-style-layout
]