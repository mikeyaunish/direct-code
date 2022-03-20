Red [
	Title: "user-script-published.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup:[
    comment {This script is designed to work in conjunction with Direct Code. It will not run as a 
             stand alone program because that is not what it is for.}
    change-dir first split-path current-file
    get-all-current-words-here: does [
        b: words-of system/words
    	collected: copy []
        ndx: 1 
    	foreach w b [
       		wrd-type: type? select system/words to-lit-word w 
    		if ((to-string wrd-type) <> "unset") [
    			append/only collected  reduce [ :w wrd-type ]
    		]
    	   	 	ndx: ndx + 1 
    	]
        return collected     
    ]
    get-new-system-words: function [
        /snapshot snapshot-block [ block! ]
    ][
        either snapshot [
            initial-red-words: fix-dt snapshot-block
        ][
            initial-red-words: fix-dt copy/part skip (load rejoin [ root-path %experiments/edit-vid-object/all-initial-red-words.red]) 600 copy-length    
        ]
        current-words: fix-dt copy (get-all-current-words-here)
        return difference (reduce initial-red-words) (reduce current-words)
    ]
]
;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
view user-script-published-layout: [
    Title "Direct Code User Script"
    space 0x1
    text1: text "Red Code Snippet Testing Area:" font-size 15 
    return 
    red-code: area 820x200 left  black green bold font-size 13 font-name "Courier New"   
    	on-key [ 
    	    if (event/key = #"^K") [ run-code ] 
        ]
        on-create [
            red-code/text: load rejoin [ root-path %user-script/red-code-snippet.red ]        
        ]
    space 4x4
    return 

    btn2: button gray red bold font-size 9 "Run Code / 'Left Control + K'" [ 
    	run-code
    ]
    mk-button: button "Make Button from Code above"  [
            btn-label: any [btn-label-field/text "" ]
            insert-vid-object/with-on-click/with-text "button" (to-block red-code/text) btn-label
    ]
    bl: text font-size 13 "Button Label:" right
    btn-label-field: field  218
    return 
    box 820x2 black 
    return 

    where-button: button "Window Location Tool"[
        where-window: layout [ 
            b1: button 200x200 "Click here to see window location" [
                print [ "where-window/offset = " where-window/offset ]
            ]
        ]
        view where-window
    ]

    button2: button "show image format of .PNG file" on-click [rf: request-file 
        if rf [
            img: load rf 
            ?? img
        ]
    ]
    return
buttonsnap: button "SNAPSHOT all current words" [ 
        snapshot: get-all-current-words-here
    ]
    btn007: button "list new words since SNAPSHOT" [
        new-words: get-new-system-words/snapshot snapshot
        pe new-words
    ]
    do [
        run-code: does [
            do red-code/text 
    	    save rejoin [ root-path %user-script/red-code-snippet.red ] red-code/text         
        ]
        
    ]
    
    
    
]