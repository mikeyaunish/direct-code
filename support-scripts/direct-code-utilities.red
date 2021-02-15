Red [ Title: "direct-code-utilities"]

copy-file: func [
    Source [file! url!]
    Destination [file!]
][
    write/binary Destination read/binary Source
]

string-to-block: function [
    s [string!]
    /no-indent
][
    if s = none! [ return [] ]
	lines: split s "^/"
	res: copy ""
	if ((trim (copy lines/1)) = "") [
		lines: skip lines 1
	]
	foreach l lines [
	    either no-indent [
	        append res rejoin [ l "^/" ]
	    ][
	        append res rejoin [ "    " l "^/" ]    
	    ]
	]
	remove back tail res 
	post-fix: either  ((last res) = #"^/") [ "]" ][ "^/]"]
	return rejoin [ "[^/" res post-fix ]
] 

un-block-string: function [ b [string!] ] [
    trim/head (trim/tail b)
    lines: split b "^/"
    if ((first lines) = "[") [ remove lines ]
    if ((last lines) = "]") [ remove back tail lines ]
    res: copy ""
    foreach l lines [ 
        append res rejoin [ l newline ]
    ]
    remove back tail res 
    return res
]

find-object-name: function [this-obj] [
	all-words: words-of system/words
	foreach wrd all-words [
    	if all [
            (value? in system/words wrd) 
            (any-object? get in system/words wrd) 
            (this-obj = (get in system/words wrd)) 
            ((copy/part (to-string wrd) 2) <> "--") 
        ][
    	    return to-string wrd                                                                                                                          
    	]
    ]
	return "*unusable-no-name*"
] 

string-is-pair?: function [ 
	str [ string! ] {string to test}
][
	nums: charset "-0123456789"
	parse str [ any nums "x" any nums ] 
]

string-is-word?: function [ 
	str [ string! ] {string to test}
][
	if all [ 
		(attempt [aword: to-word str]) 
		( (mold aword) = str ) 
	][ 
		return true 
	]
	return false
]
string-select: function [ 
	haystack [ string! ] {String to search through}
	needle   [ string! ] {String to select on. Next word will be returned}
][
	trim/with (select (split haystack " ") needle) "^/"
]

all-to-logic: function [v] [
	return switch/default v [
		true  [ true  ] 
		false [ false ]
	][   to-logic v	  ]
]

multi-split: function [ 
	series [ any-string! ]
	dlm [ block! ] {block of delimiters}
][
	foreach d dlm [
		res: split series d
		either ( d = last dlm) [ 
			series: res
		][
			series: form res
		]
	]
	remove-each i series [ i = "" ]
	return series
]

compare-objects: func ['a 'b /show-diffs ][
    a: get a
    b: get b
	diff-list: copy []
    foreach [word val] body-of a [
		either any [ (any-function? :val ) ((type? val) = object!)  ] [
		][
	        either equal? :val get in b reduce (to-lit-word word) [
    	    ][
				if show-diffs [
					append diff-list to-word word					
				]
			]
		]
    ]
	return diff-list
]
safe-face-copy: func [ obj ] [
	res-blk: copy []
	foreach [ var val ] ( body-of obj ) [
		if not any [
			(type? :val) = object! 
			(type? :val) = function! 
		][
			append res-blk reduce [ to-set-word :var :val ] 
		]
	]
	return object res-blk
]

get-terse-face: function [ obj-name [string!] ] [
	temp-obj: safe-face-copy get to-word obj-name
	return temp-obj
]

link-offset: func [left right] [
	left/offset/y: to integer! right/offset/y - (divide (left/size/y - right/size/y ) 2)
    left/offset/x: to integer! right/offset/x - (divide (left/size/x - right/size/x ) 2)
]

popup-help: func [
    "Displays a popup help message"
    msg [string!]  "Message to display"
    /offset the-offset [ pair! ]
    /close
    
][
    if close [
        close-it
        exit
    ]
    if not offset [
        ;the-offset: 50x50        
    ]
    either offset [
        view-options: compose [ offset: (the-offset) ]    
    ][
        view-options: copy []
    ]
    view/flags/options --alert-window: layout/tight [
        t: text msg font-size 11 center return
        do [
            close-it: does [
                unview/only --alert-window
            ]
        ]
    ][ ;-- flags
        popup no-title
    ]
    view-options
]

get-uid: does [
	return replace/all replace/all (to-string now/time/precise) ":" "" "." ""
]

find-in-array-at: function [ 
    blk [any-type!] 
    at-loc [integer!] 
    find-this 
    /with-index 
    /every 
    /local ndx i collected
    
][
	;prin "" ;-- ADDING THIS LINE FIXES the crash when using: Red 0.6.4 for Windows built 8-Jan-2021/16:47:49 
	
	collected: copy []
	if ((length? blk) < 1) [
	    return false
	]
	ndx: 1 
	foreach i blk [ 
		if find-this = (pick i at-loc) [        
			either with-index [                 
			    either every [
			                                    
                    append/only collected reduce [ i ndx ]
			    ][                             
			        return reduce [ i ndx ]	    
			    ]
			][                                  
			    either every [                  
			        append/only collected i
			    ][                              
			        return i                    
			    ]
			]
		]
		ndx: ndx + 1
	]
	
	if every [
	    either ((length? collected ) = 0 ) [
	        return false
	    ][
	        return collected
	    ]
	]
	return false	
]

index-of-value: function [ 
    {Example usage: index-of-value [ at 10x12 button  "hello"] 'at pair! 
     Will return true.}
    obj-blk [block!]
    key-word [word!]
    value-type [datatype!]
][ 	
    direct-key-words: [ 'at ] ; keywords that point DIRECTLY to the correct position
    valid-pre-words: [ left center right top middle bottom bold italic underline hidden ]
    valid-pre-types: reduce [ string! pair! tuple! integer! path! paren! date! block! ]
	key-word: to-lit-word key-word
	if (find direct-key-words key-word )[
	    either (sel: find obj-blk key-word) [
	        return ((index? sel) + 1)    
	    ][
	        return false
	    ]
	]
    ; all other key-words look for the value-type
    ret-ndx: 0
	either ( key-pos: find obj-blk key-word ) [
	    type-blk: collect [ foreach i obj-blk [ keep (type? i ) ] ]
	    append valid-pre-words key-word
	    key-pos-ndx: index? key-pos
    	while [ ret-ndx = 0 ] [
    	    either (fnd: find (skip type-blk key-pos-ndx ) value-type ) [ ; value-type positions is located
    	        fnd-ndx: index? fnd 
    	        previous-word: pick obj-blk  (fnd-ndx - 1)
    	        previous-type: pick type-blk (fnd-ndx - 1)
    	            	        
    	        if all [ 
    	            (previous-type = word!) 
    	            (not find valid-pre-words previous-word)
    	            (value? to-lit-word previous-word )
    	        ][
    	            previous-type: type? get previous-word
    	        ]
    	        either any [ 
    	            ( fpw: find valid-pre-words previous-word ) 
    	            ( fpt: find valid-pre-types previous-type ) 
    	        ][ ; previous item is either a valid word! or type!
    	            ret-ndx: fnd-ndx
    	        ][
    	           key-pos-ndx: fnd-ndx  
    	        ]
    	    ][
    	        return false
    	    ]
    	]
	][
	    return false
	]
	return ret-ndx
]


create-modified-source: func [ 
    source-text  [ string! ] {Original source code}
    source-block [ block!  ] {Original souce code - in block format}
    change-block [ block!  ] {Changed source code - in block format}
    change-index [ block!  ] {Index values where changes need to happen}
    /inserted
][
    
    p-bdy: copy []
    chg-blk-ndx: 0
    ci-offset: 1
    ci-length: length? change-index
    curr-change-index: pick change-index ci-offset
    spaces: [ any [" " | "^/" | "^-"]]
    change-block: to-parse-input-block change-block
    foreach i change-block [
        chg-blk-ndx: chg-blk-ndx + 1
        either ( curr-change-index = chg-blk-ndx )[
            src-val: pick source-block curr-change-index
            new-val: pick change-block curr-change-index
            either inserted [
                if ((type? new-val) = string!) [ new-val: form-string new-val ]
                new-val: rejoin [ new-val " " ]
                append p-bdy compose [ insert (new-val) ]
            ][
                make-parse-rule src-val
                append p-bdy compose/only [ remove thru (make-parse-rule src-val) insert (mold new-val) ]    
            ]
            ci-offset: ci-offset + 1
            either ci-offset > ci-length [
                break        
            ][
                curr-change-index: pick change-index ci-offset
            ]
        ][
            append p-bdy compose/only [ (make-parse-rule i) spaces ]    
        ]
    ]
    parse-res: parse source-text [  
        some [ 
            p-bdy
        ]
    ]
    return source-text 
]

compare-object-contents: function ['a 'b /return-diffs ][
    a: get a
    b: get b
	diff-list: copy []
    foreach [word val] body-of a [
		either any [ (any-function? :val ) ((type? val) = object!)  ] [
		][
	        either equal? :val get in b reduce (to-lit-word word) [
    	    ][
				if return-diffs [
					append diff-list to-word word					
				]
			]
		]
    ]
	return diff-list
] 

requester-window-escape: func [ code req-obj-name /options win-opts ][
    if not options [ win-opts: copy [] ]
    return compose/deep [ 
	    actors: object [
    		on-key: func [face event] [
    			switch event/key [
    				#"^["  [ (code) ]
    			]
    		]
    		on-close: func [ face event ] [
    		    (code)
    		]
            on-menu: func [face [object!] event [event!]][ 
                switch event/picked [
                    highlight-object [ do-to-object (req-obj-name) "highlight" ]
                    copy-object-to-clip [ do-to-object (req-obj-name) "copy-to-clip"  ]
                    delete-object [ do-to-object (req-obj-name) "delete"  ]
                ] 
            ]     		
	    ]
	    (win-opts)
	]
]
spaces: [ any [" " | "^/" | "^-"]]

point-in-triangle?: function [
    pt [pair!]
    v1 [pair!]
    v2 [pair!]
    v3 [pair!]
][
    sign-of-point: function [ p1 p2 p3 ] [
        return ( ((p1/x - p3/x) * (p2/y - p3/y)) - ((p2/x - p3/x) * (p1/y - p3/y)) )
    ]        
    d1: sign-of-point pt v1 v2
    d2: sign-of-point pt v2 v3
    d3: sign-of-point pt v3 v1
    has-neg: any [ (d1 < 0)  (d2 < 0)  (d3 < 0) ]
    has-pos: any [ (d1 > 0)  (d2 > 0)  (d3 > 0) ]
    return not all [ (has-neg) (has-pos)]
]

closure: func [
    vars [block!] "Values to close over, in spec block format"
    spec [block!] "Function spec for closure func"
    body [block!] "Body of closure func; vars will be available"
][
    func spec compose [(bind body context vars)]
]
