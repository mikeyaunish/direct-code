Red [
	Title: "zero-out-tests-page-TEMP.red"
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
card-3-layout: [
button1: button "card 1" [ load-and-run %card-1.red ]
button2: button "card 2" [ load-and-run %card-2.red ]
button3: button "card 3" [ load-and-run %card-3.red ]
button4: button "card 4" [ load-and-run %card-4.red ] return
card-indicator1: base 62x10 white loose
card-indicator2: base 62x10 white loose
card-indicator3: base 62x10 red loose
card-indicator4: base 62x10 white loose return
at 52x138 base1: base 506x142 127.132.245.0 white black "base1"
at 73x174 text1:  text 443x59 font-size 30 on-create [ text1/text: user-name ]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view card-3-layout
]