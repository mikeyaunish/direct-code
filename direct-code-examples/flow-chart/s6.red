Red [
	Title: "s6.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup:[

]
;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
view s6-layout: [
size 600x300
button "Start Procedure" [ load-and-run %start-here.red ]  return
text font-size 13 "Is the computer on?"
button1: button "" [ load-and-run %s2.red ]
button2: button "No" [ load-and-run %s5.red ] return 
text2: text font-size 13 "Have you tried pushing the power button?" 325x25
button1: button "Yes" [ load-and-run %s6.red ]
button2: button "" [ load-and-run %s5.red ] return 
text3: text font-size 13 "Excellent - we have a job for you in technical support." 411x25
]