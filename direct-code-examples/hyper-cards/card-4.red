Red [
	Title: "card-4.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup:[
#include %../direct-code-stand-alone.red
]
;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
view card-4-layout: [
button1: button "card 1" [ load-and-run %card-1.red ]
button2: button "card 2" [ load-and-run %card-2.red ]
button3: button "card 3" [ load-and-run %card-3.red ]
button4: button "card 4" [ load-and-run %card-4.red ] return
card-indicator1: base 62x10 white loose
card-indicator2: base 62x10 white loose
card-indicator3: base 62x10 white loose
card-indicator4: base 62x10 red loose
return
text1: text 700x80 font-size 40 white green on-create [ text1/text: user-name ]
]