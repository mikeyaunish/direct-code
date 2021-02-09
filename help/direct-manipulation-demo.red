Red [
	Title: "direct-manipulation-demo.red"
	Needs: View
	Comment: "Generated with Direct Code"
]


do setup:[
	blue-box-position: 471x118
    ;--               /\ /\ /\
    ;--               || || || 
    ;--********* WATCH THIS CODE CHANGE ***************
    ;--******** WHEN YOU MOVE AND DROP THE BLUE BOX ***
    ;--************************************************
]


view [
    style txt: text font-size 14
	button "<< GO BACK" font-size 12 bold [ load-and-run %../welcome-to-direct-code.red ] return
	h3 "Direct Manipulation Example" underline return return 
    txt bold underline "Select the blue box" txt bold " ---->>------->>----->>------->>"  return txt bold underline "by doing one of the following:" return txt bold "1.) Click on the box with the middle mouse button" return txt bold "          OR" return
    txt bold "2.) Roll the mouse over the blue box and press the Control and ~ key."
    ;-*******************************
    ;-* BLUE BOX VARIABLE USED HERE *
    ;-* || || || || || ************** 
    ;-  \/ \/ \/ \/ \/
    at blue-box-position blue-box: base 50x50 blue return return 
    txt "When you see the cross hairs you can drag the box to a new location by pressing the" return txt "left mouse button down and dragging the box." return txt "Once you drop the blue box, notice how the variable 'blue-box-position' defined in the" return txt "'Setup Code' area in the top left panel changes."
    return 
    base 700x1  return
    ;--                                             **************************************
    ;--                                             * AS YOU MOVE AND DROP THE GREEN BOX *
    ;--                                             ******* WATCH THIS CODE CHANGE *******
    ;--                                                       || || || ||
    ;--                                                       \/ \/ \/ \/ 
    text bold font-size 14 "Select and move the green box -->" green-box: base 50x50 green return 
    ;--
    text font-size 14  "Notice how the layout changes and the source code in the bottom left panel changes as well." return
]
