Red [
	Title: "user-script.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
s4-layout: [
size 600x300
button "Start Procedure" [ load-and-run %start-here.red ]  return
text1: text font-size 13 "Is the computer on?"
button1: button "Yes" [ load-and-run %s2.red ] 
button "" loose return 
text2: text font-size 13  "Is there any smoke or fire?"
button2: button "Yes" loose [ load-and-run %s3.red ] 
button "" loose return
text3: text font-size 13  "Quickly, turn it OFF - do you still want to use it?"
button3: button "Yes" [ load-and-run %s4.red ] 
button4: button "" [ load-and-run %s9.red ]  return 
text4: text font-size 13  "Sorry, unable to use a computer that was just on fire." 412x22
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view s4-layout
]