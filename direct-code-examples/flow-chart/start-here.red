Red [
	Title: "start-here.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup:[
#include %../direct-code-stand-alone.red
]
;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
view start-here-layout: [
size 600x300
title "Start Procedure" 
button "Start Procedure" [ load-and-run %start-here.red ]  return
text1: text font-size 13 "Is the computer on?"
button1: button "Yes" [ load-and-run %s2.red ]
button2: button "No" [ load-and-run %s5.red ]
]