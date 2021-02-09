Red [
	Title: "quick-start-guide.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup:[

]
;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
view quick-start-guide-layout: [
style txt: text font-size 13
button1: button "<< Go back to Welcome Page" font-size 12 bold center [ load-and-run %welcome-to-direct-code.red ] 
title1: h3 "   Quick Start Interactive Guide   " underline return 
at 477x58 blue-box: base 7.14.241.0 98x88 loose 1.2.225.0 white font-size 12 bold "BLUE BOX" 
;-- /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\
;-- || || || || || || || || || || || ||  
;--**** WATCH THIS CODE CHANGE ****************
;--**** AS YOU MAKE CHANGES TO THE BLUE BOX ***



t0: txt underline "Select the blue box" txt bold " ------>>------->>----->>------->>"  return 
t2: txt "By doing one of the following two things:" return 
t3: txt "    1.) Click on the BLUE BOX with the middle mouse button" return 
t4: txt "    2.) Roll the mouse over the BLUE BOX and press the Control and ~ key." return
t5: txt "        (That is the Control and the Tilde key)" return
t6: txt "You will see the 'VID Object Editor' pop up below this window." return 
t7: txt {Here is how the Object Editor works} return
image1:  image  %vid-object-editor.jpg return 
at 61x334 area1: area 416x21 {<-- This menu item allows a number of actions against the 'blue box' object} loose
note1: text font-size 12 {Notice how the source code (on the left) changes as you modify the different object values.^/You can also click and drag the BLUE BOX around (because it is 'loose') which will also change the source code.^/Any graphical element on this page can be changed in the same way. For more help select the menu: 'Help/Direct Code Help'} 

at 355x423 area2: area 325x21 {<-- Click on arrows or click and drag to change coordinates} loose
at 355x452 area12: area 325x21 {<-- Click on arrows or click and drag to change coordinates} loose

at 355x513 area3: area 223x21 "<-- Click here to see a colour requester" loose
at 353x311 area4: area 245x21 "<-- Close requester or press the Escape key" loose
at 355x482 area5: area 325x22 {<- click here for a text requester (for long or mulitline text)} loose
]
