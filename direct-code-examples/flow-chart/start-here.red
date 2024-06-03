Red [
	Title: "user-script.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [
	load-and-run: function [
	    filename [file!] 
	    /no-save
	][
	    either (value? 'dc-initialized) [
	        dc-load-direct-code filename 
	        either no-save [
	            run-and-save/no-save ""
	        ] [
	            run-and-save "dev-load-and-run"
	        ]
	    ] [
	        filename: clean-path filename 
	        if (exists? filename) [
	            unview/all 
	            do filename
	        ]
	    ] 
	]
]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
start-here-layout: [
size 600x300
title "Start Procedure" 
button "Start Procedure" [ load-and-run %start-here.red ]  return
text1: text font-size 13 "Is the computer on?"
button1: button "Yes" [ load-and-run %s2.red ]
button2: button "No" [ load-and-run %s5.red ]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view start-here-layout
]