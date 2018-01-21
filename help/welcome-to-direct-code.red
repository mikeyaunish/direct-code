Red [
	Title: "welcome-to-direct-code.red"
	Needs: View
	Comment: "Generated with Direct Code"
]


do setup:[
	red-box-position: 474x368
    ;--               /\ /\ /\
    ;--               || || || 
    ;--********** WATCH THIS CODE CHANGE **************
    ;--********** WHEN YOU MOVE AND DROP THE RED BOX **
]


view [
    style text: text font-size 14
    H3 "Welcome to 'Direct Code'" underline bold
    return
    area font-size 12 700x300 {Direct Code has been built on the foundation of livecode-enhanced, which was written by Nenad 
Rakocevic and Didier Cadieu.  

The Red code on the left side is creating everything you see on this right side.

This is my first attempt at a 'direct manipulation' environment for Red, where you are able
to edit your Red code like normal (on the left) or you can change the source code by directly 
manipulating the objects rendered (on the right side).

As a proof of concept the only ACTION currently available is to MOVE 'named' objects on 
the right side and have the code reflect those changes (on the left). This is the very first 
steps to a WYSIWYG environment for programming in Red.}
    return
    button "See a demonstration of Direct Manipulation >>" font-size 12 bold [
    	load-and-run %direct-manipulation-demo.red 
    ]
     
    
]
