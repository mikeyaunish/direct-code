Red [
	Title: "get-vid-code-text.red"
	Version: 10.0
	Needs: View
]
  

flatten-block: function [
	block [block!]
	/local result pos rule
] [
	result: make block! 0
	blk: copy ""
	parse block rule: [
		any [
		    pos:
			set blk block! ( 
    	        append result #"[" 
    	        append result flatten-block blk 
    	        append result #"]" 
			)
			| skip (insert/only tail result first pos)
		]
	]
	result
]

flatten-paren: function [
	block [block!  paren!]
	/local result pos rule
] [
	result: make block! 0
	blk: copy ""
	parse block rule: [
		any [
		    pos:
			set par paren! ( 
    	        append result #"(" 
    	        append result flatten-paren par 
    	        append result #")" 
			)
			| skip (insert/only tail result first pos)
		]
	]
	result
]

to-parse-input-block: function
[
	block [block!]
	/local flat-block
] [
    flatten-paren flatten-block block
]



get-vid-code-block: func [  
    red-code [ string! ]
    obj-name [ word! ]
][
    get-styles: function [ code-block ] [
        return parse code-block [
            collect any [
                'style ahead keep set-word!    
                | skip 
            ]
        ]
    ]
    red-block: to-parse-input-block to-block red-code
    red-code: red-block
    defined-styles: get-styles red-code
    vid-object-names: [ 
        'window | 'base | 'button | 'text | 'field | 'area | 'check | 'radio | 'progress | 'slider | 
        'camera | 'text-list | 'drop-list | 'drop-down | 'calendar | 'panel | 'group-box | 'tab-panel | 
        'h1 | 'h2 | 'h3 | 'h4 | 'h5 | 'box | 'image | 'across | 'below | 'return | 'space | 
        'origin | 'pad | 'do | 'rich-text |
        'WINDOW | 'BASE | 'BUTTON | 'TEXT | 'FIELD | 'AREA | 'CHECK | 'RADIO | 'PROGRESS | 'SLIDER | 
        'CAMERA | 'TEXT-LIST | 'DROP-LIST | 'DROP-DOWN | 'CALENDAR | 'PANEL | 'GROUP-BOX | 'TAB-PANEL | 
        'H1 | 'H2 | 'H3 | 'H4 | 'H5 | 'BOX | 'IMAGE | 'ACROSS | 'BELOW | 'RETURN | 'SPACE | 
        'ORIGIN | 'PAD | 'DO | 'RICH-TEXT
    ]
    foreach i defined-styles [
        append vid-object-names reduce [ '| (to-lit-word i ) ]
    ]    
    
    obj-ndx: -10
    set-word-ndx: -10
    at-ndx: -10
    obj-positions: copy []
    break-next: 'false
    parse red-code [
    	any [
            copy -at at-mark: 'at (
                at-ndx: index? at-mark
            )
            | copy -set-word set-word-mark: set-word!  (
			    set-word-ndx: index? set-word-mark 
			)            
			| copy -object obj-mark: vid-object-names (
			    obj-ndx: index? obj-mark
			    obj-start-pos: obj-ndx
			    prepend-msg: copy ""
			    either ((obj-ndx - set-word-ndx) = 1)[ ; previous set-word applies to this object
			        obj-start-pos: obj-ndx  - 1
			        cur-obj-name: to-word -set-word/1
			        prepend-msg: rejoin [ " OBJ-NAME:" -set-word ":"]
			    ][
			        cur-obj-name: 'anonymous
			        prepend-msg: rejoin [ " OBJ-NAME:<anon>"]
			    ]
			    if ((obj-start-pos - at-ndx) = 2)[ ; 'at applies to this object 
			        prepend-msg: rejoin [ prepend-msg " using (AT)"  ]
			        obj-start-pos: obj-start-pos  - 2
			    ]
			    append/only obj-positions reduce [ cur-obj-name obj-start-pos ]
			) 
			| skip 	
    	]
    ]
    return either (fnd-obj: find-in-array-at/with-index obj-positions 1 obj-name) [
        ; Example format of fnd-obj: [[button1 11]     3]
        ;                              OBJ     OFFSET  INDEX
        code-length: either (fnd-obj/2 = (length? obj-positions)) [
            (length? red-code) - fnd-obj/1/2 + 1
        ][
            (pick (pick obj-positions (fnd-obj/2 + 1)) 2) - fnd-obj/1/2
        ]
        str-pos: ( fnd-obj/1/2 - 1)
        z: copy/part skip red-code str-pos code-length
        return z
    ][
        'false
    ]
]

vid-code-mold: function [ v ] [
    return switch/default (to-string type? v) [
         "char"   [ v ]
         "string" [ v ]
    ][ mold v ]
]
quotes-to-curly: func [ str ] [
    curly-str: copy str
    remove/part (skip (tail str) -1 ) 1
    remove/part str 1 
    insert str "{"
    append str "}"
]

mold-no-quote: func [ s ][
    remove head ( remove back tail ( mold s ))
]

form-string: func [ 
    {forces string to be surrounded by either quotes (default behaviour)
    or curly brackets}
    s [string!]
    /curly {surround string with curly brackets}
    /trim {remove and replace existing quotes or curly}
    
][
    t: copy s
    if trim [
        bk: back tail t 
        if any [ ( bk/1 = #"}") ( bk/1 = #"^"" ) ] [ remove/part bk 1 ]
        fr: head t
        if any [ ( fr/1 = #"{") (fr/1 = #"^"" ) ][ remove fr ]
    ]
    either curly [
        t: curly-string head t    
    ][
        t: quote-string head t
    ]
    return t
]

curly-string: func [ s ] [ return head ( insert ( append copy s "}") "{" ) ]
quote-string: func [ s ] [ return head ( insert ( append copy s {"}) {"} ) ]

mold-insides: func [ s ] [
    s: mold s
    remove s
    remove back tail s 
    head s
]

create-parse-string-rule: function [ 
    {convert plain string into universal parse rule}
    str [string!]
][
    cpy-str: copy str    
    str: mold-insides str ; This is to handle special characters


    
    str0: copy cpy-str
    str1: form-string/trim       copy str
    str2: form-string/trim       copy cpy-str
    str3: form-string/curly/trim copy str
    str4: form-string/curly/trim copy cpy-str
    str5: form-string/curly copy cpy-str
    str6: form-string       copy cpy-str
    str7: form-string/curly form-string cpy-str
    
    ret-val: reduce [ str1 '| str2 '| str3 '| str4 '| str5 '| str6 '| str7 '| str0 ]
    return ret-val
]

blank-out-comments: function [ src ] [
    s: copy src
    comments-found: get-comments s
    foreach [ line-num comment-str ] comments-found [
		blanks: pad (copy "") (length? comment-str)
		stl: skip-to-line s line-num
		replace stl comment-str blanks
    ]
    return head s
]


skip-to-line: function [ s line-num ] [
	if line-num = 1 [ return s ] 
	fnd-cnt: 1
	fnd-pos: s
	while [ fnd-cnt < line-num ] [
		either ( fnd-pos: find (skip fnd-pos 1) "^/" ) [
			fnd-cnt: fnd-cnt + 1 
		][
			break
		]
	]
	either fnd-cnt = line-num [
		return skip fnd-pos 1
	][
		return false
	]
]


make-parse-rule: function [ v ] [
    return switch/default (to-string type? v) [
         "char"   [ 
            return v 
         ]
         "string" [  
            w: create-parse-string-rule v 
            return w
         ]
    ][ 
        return mold v 
    ] 
]

get-vid-code-text: function [ txt-src blk-src /return-positions /extern dc-src-txt dc-p-rule ] [ 
    result: copy ""
    blk-src: to-parse-input-block blk-src
    
    p-beg-code: [( 
            str-ndx: (index? beg) - (length? vid-code-mold first blk-src ) - 1 
        )
    ]
    p-rule: compose/only [ 
        spaces
        (make-parse-rule first blk-src ) beg: (p-beg-code/1)
    ]
    p-end-code: [
        ( 
            end-ndx: ((index? nd))  
            
            result: copy/part (skip txt-src str-ndx) (end-ndx - str-ndx - 1)
            positions: reduce [ str-ndx end-ndx ]
        )
    ]
    p-mid-vals: copy/part skip blk-src 1 ((length? blk-src) - 2)
    p-mid: copy []
    foreach i p-mid-vals [
        amid-code: [(
        )]
        mid-code: compose/deep [
        ]
        mid-code: to-paren mid-code

        xmid-code: compose [
        ]
        append p-rule compose/only [ 
            spaces 
            (make-parse-rule i) end-mid: (mid-code)
        ]
    ]
    append p-rule compose/deep/only [                                 ;- LAST parse rule
        spaces
        (make-parse-rule last blk-src) nd: (p-end-code/1) 
        | skip 
    ]
    cleaned-src: blank-out-comments (copy txt-src)
    p: parse cleaned-src [  
        some [ 
            p-rule
        ]
    ]
    either return-positions [
        return reduce [ result positions ]
    ][
        return result    
    ]
    
]
 
