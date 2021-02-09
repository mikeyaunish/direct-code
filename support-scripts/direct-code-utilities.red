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
	return rejoin [ "[^/" res "]" ]
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

change-function-in-object: func [ 
    obj 
    func-name 
    func-body 
    /top
][
    action: either top [:insert ][:append] ; defaults to append
	cur-func: select obj (to-lit-word func-name)
	f-spec: spec-of :cur-func
	f-body: body-of :cur-func
	action f-body func-body
	new-line f-body true
	new-func: func f-spec f-body 
	do [ to-set-path [ obj (to-word func-name) ] :new-func ]
]

track-changes: closure [
	tracked-objects: [] [block!] 
	tracked-deep-objects: [] [block!] 

][	
	obj-name [string!]
	/deep
	/local track-block current-version obj-word last-version the-obj track-head
][ 
    triggers: [ 'offset ]   ; dc-matrix/<obj-type>/<changed-field>
                            ; will eventually be matching against track changes 'word 
	track-block: either deep [ :tracked-deep-objects ] [ :tracked-objects ]
    current-version: get-terse-face obj-name
    obj-word: to-word obj-name
    last-version: track-block/:obj-word
    the-obj: get obj-word
    copy-obj-name: copy obj-name
    either last-version [
		obj-changes: compare-objects/show-diffs last-version current-version
		track-head: either deep [ "|  DEEP TRACK|" ] [ "|NORMAL TRACK|" ]
		foreach changed-field obj-changes [
			a: last-version/:changed-field
			b: current-version/:changed-field
			if find triggers changed-field [
			    obj-type-to-word: the-obj/type
			    action-object-name: dc-matrix/:obj-type-to-word/:changed-field
			    dc-ctx/update-source-code obj-name action-object-name
			]
		]
		track-block/:obj-word: current-version
	][
	    insert track-block reduce [ to-set-word obj-name get-terse-face obj-name ]
	]
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
