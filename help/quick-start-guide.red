Red [
	Title: "quick-start-guide.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup:[

]
;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
view quick-start-guide-layout: [
    title1: h3 "Quick Start Interactive Guide " underline 
    style txt: text font-size 12
    return 
    below

    blue-box: base loose font-size 12 font-color 255.255.255 bold "BLUE BOX" 7.14.241
    ;-- /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\
    ;-- || || || || || || || || || || || ||  
    ;--**** WATCH THIS CODE CHANGE ****************
    ;--**** AS YOU MAKE CHANGES TO THE BLUE BOX ***

    at 94x59 t0: txt font-size 15 {<= Select the blue box, by doing one of two things:} 
     
     


    across space 8x4
    return 
    at 570x68 image1:  image 200.200.200 %vid-object-editor2.gif  
    at 110x97 note1: text font-size 12 {  1.) Click on the blue box with the middle mouse button^/  2.) Roll the mouse over the BLUE BOX and press ^/      the Control and ~ key.  (That is the Control and the ^/      Tilde key)^/^/You will see the 'VID Object Editor' window. ^/   (as shown here) -------------------------------------------> ^/^/With the editor you can change any VID object values that you wish. Notice how the source code (on the left) changes as you modify the different object values.^/^/Any graphical element on this page can be changed in the same way. Combine this feature with the ability to add any GUI object to your project through the 'Insert' menu and now you have total control over your GUI creations.^/For more information select the menu: 'Help/Direct Code Help'}402x550  
    at 184x462 button1: button "Or Click Here for Direct Code Help" 254x30 loose font-size 12 on-click [do rejoin [root-path %help/direct-code-help.red]]
]
