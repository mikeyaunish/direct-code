Red [
	Title: "user-script.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
s2-layout: [
size 600x300
button4: button "Start Procedure" [ load-and-run %start-here.red ]  return
text1: text font-size 13 "Is the computer on?"
button1: button "Yes" [ load-and-run %s2.red ] 
button2: button "" loose return 
text1: text font-size 13  "Is there any smoke or fire?"
button2: button "Yes" loose [ load-and-run %s3.red ] 
button3: button "No" loose [ load-and-run %s10.red ] 
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view s2-layout
]