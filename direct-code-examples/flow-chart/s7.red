Red [
	Title: "user-script.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
s7-layout: [
size 600x300
button "Start Procedure" [ load-and-run %start-here.red ]  return
text font-size 13 "Is the computer on?"
button1: button "" [ load-and-run %s2.red ]
button2: button "No" [ load-and-run %s5.red ] return 
text2: text font-size 13 "Have you tried pushing the power button?" 325x25
button1: button "" 
button2: button "No" [ load-and-run %s7.red ] return 
text4: text font-size 13 "Telepathic power control has not yet been implemented.^/Try again tomorrow." 439x48
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view s7-layout
]