Red [
	Title: "welcome-to-direct-code.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
welcome-to-direct-code-layout: [
    style text: text font-size 14
    h3-text: H3 "Welcome to Direct Code" underline bold
    return
    area1: area font-size 12 580x220 

{Direct Code has been built on the foundation of livecode-enhanced, which was^/original written by Nenad Rakocevic and Didier Cadieu.^/^/The Red code on the left side is creating everything you see on this right side.^/^/All of the 'livecode' features (changing code and seeing results instantly) are^/still available. Direct Code adds a 'VID Object Editor' that allows ^/'direct manipulation' of almost every facet (or attribute) of every VID Object.^/^/In short, a WYSIWYG for Red.^/^/}
    return
    at 11x292 button1: button 336x25 " See the quick start guide to Direct Code" font-size 12  center bold [
    	load-and-run %quick-start-guide.red 
    ]
     
    
    
    
    
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view welcome-to-direct-code-layout
]
