Red [
	Title: "card-1.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup:[
#include %../direct-code-stand-alone.red
if (not value? 'user-name) [ user-name: copy "Fred" ] if (not value? 'user-name) [ user-name: copy "" ] ; create a place holder if it doesn't exist
]
;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
view card-1-layout: [
button1: button "card 1" [ load-and-run %card-1.red ]
button2: button "card 2" [ load-and-run %card-2.red ]
button3: button "card 3" [ load-and-run %card-3.red ]
button4: button "card 4" [ load-and-run %card-4.red ] return
card-indicator1: base 62x10 red loose
card-indicator2: base 62x10 white loose
card-indicator3: base 62x10 white loose
card-indicator4: base 62x10 white loose return
text1: text font-size 14 {This is a 'multi-card' set of Red programs. Similar to how Hypercard worked.
You can move between 'cards' and edit them within the Direct Code environment.

Each card is it's own separate program except you are able to share global Red variables 
between cards.} return 

text2: text font-size 14 right  "user-name?: " gray white
field1: field 200x27 font-size 14 on-create [ field1/text: user-name ] [ user-name: field1/text ] return 
text3: text font-size 14 {Enter a different name above and click on the 'card 2' button to see the 'user-name' 
variable in card 2}
]