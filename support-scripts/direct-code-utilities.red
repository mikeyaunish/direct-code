Red [ 
    Title: "direct-code-utilities"
    Date: 10-Feb-2022
]

show-current-folder: does [
    cur-dir: to-local-file what-dir
    split-slash: split cur-dir "\"
    drive-letter: rejoin [ split-slash/1 "\" ]
    batch-script: copy drive-letter 
    append batch-script rejoin [ newline {explorer.exe "} cur-dir {"}]
    write %show-current-folder.bat batch-script
    call/wait {show-current-folder.bat}
    delete %show-current-folder.bat
]


to-valid-font-size: func [ v ] [
	return either (v > 0) [ v 
	][ 
		request-message rejoin [ v " is not a valid font size. Making the font size '9'" ]
		9 
	] 
]

to-valid-file: func [ val ] [
    if file? val [ 
        return val 
    ]
    if ((first val ) = #"%") [ remove val ]
    either find val {"} [               ;-- " match orphaned quote
        return to-file load val
    ][
        return to-file val
    ]
]

de-block-string: function [ s ][
    r: trim copy s 
	if ((first r) = #"[") [ remove r ]
	if ((last r) = #"]") [ remove back tail r ]    
	return r
]

de-quote-string: function [ s ][
    r: trim copy s 
	if ((first r) = #"^"") [ remove r ]
	if ((last r) =  #"^"") [ remove back tail r ]    
	return r
]

de-curly-string: function [ s ][
    r: trim copy s 
	if ((first r) = #"{") [ remove r ]
	if ((last r) =  #"}") [ remove back tail r ]    
	return r
]

string-to-valid-type: function [
	val [string!]
][
    scan-res: scan/next val
    val-type: first scan-res
    switch (to-string val-type)[
        "word" [
            if val = "true" [ return true ] 
            if val = "false" [ return false]    
        ]
        "block" [
            val: de-block-string val
        ]
        "date" [
            return load val 
        ]
        "error" [
            request-message/size rejoin [ "Unable to turn the string below into a valid data format.^/" form val ] 600x400
            return ""
        ]
    ]
    return to val-type val 
]

request-a-file: func [ 
    current-file [file! string!] {current file - if there is one, otherwise ""}
    message [ string! ] {Message to display}
    prompt [ string! ] {Prompt that appears in front of field}
    /skip-button
][ 
    ret-val: copy ""
    return-val: func [ /cancel ][ 
        either cancel [
            ret-val: none
        ][
            ret-val: to-red-file any [ file-field/text "" ]    
        ]
        unview/only rre
    ]
    either skip-button [
        skip-btn: [ button "SKIP" 100x24 [ return-val ]]    
    ][
        skip-btn: [ button 0x0 hidden ]
    ]
    rre: layout compose [
        title "Select a File"
        across
        space 0x4
        text "" 120x24
        text message 400x48
        return
        text prompt right 120x24 font-size 10  space 0x8
        file-field: field 400x24 [ 
            return-val
        ]
        space 2x8 
        exec-pick: button "^^"  24x24 [
            if (filename: request-file ) [
                file-field/text: form to-local-file filename
            ]
        ]
        return 
        text "" 120x24
        button "OK" 100x24 [
            return-val 
        ]
        (skip-btn)
        button "CANCEL" 100x24 [
            return-val/cancel
        ]
        do [
            file-field/text: form to-local-file current-file
        ]
    ] 
    view rre
    return ret-val
] 

get-set-words: func [ in-blk [block!]] [
    ret-blk: copy []
    parse in-blk  [ any [ set sw set-word! ( append ret-blk sw ) | skip ] ]
    return ret-blk
]

mold-no-quote: func [ s ][
    remove head ( remove back tail ( mold s ))
]

unset-uid-vars: function [ 
    uid [string!]
][
    curr-words: get-all-current-words/only
    curr-words: skip curr-words 600 ;-- first 600 are roughly all red used words
    wrd-count: 1
    foreach wrd curr-words [
        if (find (to-string wrd) uid ) [
            wrd-count: wrd-count + 1
            unset wrd
        ]
    ]
]

get-all-current-words: function [
    {return all system words and types}
    /only {return only words without types}
][
    b: words-of system/words
    reduce-block: copy either only [
        [:w]
    ][
        [:w wrd-type]
    ]
    collected: copy [] 
    ndx: 1 
    foreach w b [
        wrd-type: type? select system/words to-lit-word w 
        if ((to-string wrd-type) <> "unset") [
            append/only collected reduce reduce-block
        ] 
        ndx: ndx + 1
    ] 
    return collected
]

is-whitechar?: function [ c [char! none!] ][
	whitespace: charset " ^-^/^M"
	return either (find whitespace c) [ true ][ false ]
]


to-safe-pair: function [ v ] [
	either error? try/all [
		res: to-pair v
		true
	][
		return 0x0
	][
		return res
	]
]

to-safe-integer: func [ v /local res ] [
    either error? try/all [
            res: to-integer v 
            true
        ] [
            return 0
        ] [
            return res
        ]
]


to-safe-tuple: function [ v ] [
	either error? try/all [
		res: to-tuple v
		true
	][
		return 128.128.128
	][
		return res
	]
]

to-safe-string: function [ s ] [
	return either (s = none)[
		""
	][
		to-string s
	]
]    

if-single-to-block: func [v [any-type!]][
    either [(type? v) <> block! ][
        return  to-block v  
    ][ 
		return v
	]     
]

string-to-date: function [ 
    {converts a DD-MMM-YYYY string into a date! datatype}
    s [string!]
    
][
	s: split s "-"
	return to-date to-block reduce [ 
	    (to-integer s/1) 
	    (index? find [ "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec" ] s/2) 
	    (to-integer s/3) 
	]
]

load-exportable: function [ 
	source-file [file!]
][
	do select (select (load source-file ) 'setup) 'exportable
]

refine-function: function [
    {Refines a function with the specified refinements.}
    'f {The function}
     r [any-block!] {refinements block}
    /args a  [any-block!] {argument block that match function args and refinement values}
] 
[
    if args [
        df: refine-function :f r
        to-do: compose reduce [ df ]
        foreach i a [
            append/only to-do i                            
        ]
        return to-do
    ]
    p: to-path head insert/only head copy r f
    return :p
]

fix-dt: fix-datatype: function [
    {fix all datatype values in an array} 
    array [block!] 
][
    datatype-list: [
        datatype!      unset!         none!          logic!         block!
        paren!         string!        file!          url!           char!
        integer!       float!         word!          set-word!      lit-word!
        get-word!      refinement!    issue!         native!        action!
        op!            function!      path!          lit-path!      set-path!
        get-path!      routine!       bitset!        point!         object!
        typeset!       error!         vector!        hash!          pair!
        percent!       tuple!         map!           binary!        time!     
        handle!        date!          port!          money!         ref!      
        tag!           email!         image!         event!          
    ]
    x: 0
    loop ( length? array ) [
		x: x + 1
    	val: pick array x 
    	either block? val [
    	    fix-datatype val     
    	][
    		if all [ ((type? val) = word!) (find datatype-list val) ] [
    		    set (to-path reduce [ 'array x  ]) reduce val
    		]
    	]
	]    
	return array           
]    

get-panel-styles: function [ panel ] [
    all-styles: collect [
        foreach i get-set-words to-block system/view/VID/styles [
            keep to-word i
        ]   
    ] 
    return collect [
        foreach i panel/pane [
            if not find all-styles i/options/style [
                keep i/options/style
            ]
        ]
    ]
]

offset-to-line-num: func [ text the-offset /vid ] [
    line-num: length? split ( copy/part text the-offset ) "^/"    
    return either vid [
        current-file: read/lines dc-filename
        setup-code-length: index? find current-file vid-code-marker    
        setup-code-length + line-num + 1
    ][
        line-num        
    ]
]

get-assert-parts: func [ blk [ block! ] ] [
	frt-part: []
	op-part: []
	sec-part: []
	ops: [ '= | '== | '<> | '> | '< | '>= | '<= | '=? ] 
	parse blk [
		copy frt-part to ops 
		rem-part: (op-part: rem-part/1)
		skip  sec-part: 
	]
	return reduce [ frt-part op-part sec-part ]
]



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

find-object-name: func [this-obj] [
    all-vid-names: get-set-words to-block vid-code/text 
    foreach vid-name all-vid-names [
        if all [
            (value? to-lit-word vid-name) ;-- styles don't show in this context
            (this-obj = (get to-lit-word vid-name))
        ][
            return to-string vid-name
        ]
    ]
    return "*unusable-no-name*"
]

find-object-name-ORIG: func [this-obj] [
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

all-to-logic: function [v] [ 
    return switch/default (to-word type? v) [
        integer! [
            switch/default v [
    	       0 [ false ]
    	       1 [ true ]
    	    ][
    	        true
    	    ]
        ]   
        word! [
            switch/default v [
	        	true  [ true  ] 
		        false [ false ]
	        ][
	            false
	        ]
        ]
        string! [
            switch/default v [
                "true"  [ true  ]    
                "false" [ false ]
				""      [ false ]                
            ][
                true
            ]
        ]         
        file! [
            switch/default v [
                %""    [ false ]
            ][
                true
            ]
        ]
    ][ 
        to-logic v
    ]
]

compare-objects: func ['a 'b /show-diffs ][
    a: get a
    b: get b
	diff-list: copy []
    foreach [word val] body-of a [
		either any [ (any-function? :val ) ((type? val) = object!)  ] [
		][
	        if not (equal? :val get in b reduce (to-lit-word word)) [
				if show-diffs [
					append diff-list to-word word					
				]
			]
		]
    ]
	return diff-list
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
    ;-- prin "" ;-- This fixes *** Throw Error: return or exit not in function
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

pick-deep: function [ val index [block!]] [
    res: val
    foreach i index [
        res: pick res i
    ]
    return res
]

forskip: function ['word [word!] length [integer!] body [block!]][
    unless positive? length [cause-error 'script 'invalid-arg [length]]
    unless series? get word [
        do make error! "forskip expected word argument to refer to a series"
    ]
    orig: get word
    while [any [not tail? get word (set word orig false)]] [
        set/any 'result do body
        set word skip get word length
        get/any 'result
    ]
]
    
search-in-block-at: function [ ;-- defaults to a direct match
    blk [any-type!] 
    at-loc [block!] { 1st integer = skip amount, 2nd integer and onwards determine pick offset }
    find-this 
    /with-index 
    /every 
    /find-in
    /local ndx i collected
    
][
    prin "" 
	collected: copy []
	if ((length? blk) < 1) [
	    return false
	]
	ndx: 1 
	pick-block: copy skip at-loc 1

	either find-in [
	    comparator: [ find i find-this ]
	][
	    comparator: [ find-this = i ]    
	]
	forskip blk at-loc/1 [
		(i: pick-deep blk pick-block)
		if do comparator [ 
			either with-index [                 
			    either every [
                    append/only collected reduce [ i ndx ]
			    ][                            
			        append/only collected reduce [ i ndx ] 
			        break
			    ]
			][                                  
			    either every [                  
			        append/only collected i
			    ][ 
			        append/only collected i 
			        break
			    ]
			]
		]
		ndx: ndx + 1
	]
    either collected = [] [
        return false
    ][
        return collected
    ]
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
    win-opts: any [ win-opts (copy [])]
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
                event-picked: to-string event/picked ;-- This needs to be set for this to work, compose issue?
                handler-obj-name: either face/extra/current-object-name = "" [ ;-- This is to deal with object renaming withing the evo requester
                    (req-obj-name)
                ][
                    face/extra/current-object-name
                ]
                evo-menu-handler handler-obj-name event-picked
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


which-different: func [ set1 set2 entry-size ] [	
	d: difference set1 set2 
	results: copy []
	loop-cnt: ((length? d) / entry-size )
	i: 0
	loop loop-cnt [
		entry: copy/part (skip d (i * entry-size)) entry-size
		i: i + 1
		if fnd: find set1 entry [
			append/only results reduce [ 1 entry ]	
		]
		if fnd: find set2 entry [
			append/only results reduce [ 2 entry ]	
		]
	]
	return results
]

get-next-version-name: function [ file-path ] [
	file-path-split: split-path file-path
	file-name-split: split (to-string file-path-split/2) "."
	just-name: file-name-split/1
	file-ext:  file-name-split/2
	ndx-pos: length? just-name
	foreach i (reverse copy just-name) [
	    either (not find "0123456789" to-string i ) [
	        name-part: copy/part just-name ndx-pos
	        num-part: copy (skip just-name ndx-pos  )
	        either (num-part = "") [
	            num-part: 1
	        ][
	            num-part: to-string (( to-integer num-part ) + 1 )    
	        ]
	        break
	    ][
	        ndx-pos: ndx-pos - 1
	    ]    
	]
	return to-file rejoin [ file-path-split/1 name-part num-part "." file-ext]
]

get-timestamp-string: does [
    now-time: now/precise
	now-time: rejoin [ now-time/date "-" now-time/hour "-" now-time/minute "-" to-string to-time now-time/second ]
    replace/all replace/all (replace/all now-time "/" "-" ) ":" "-" "." "-"
	return now-time
]

get-unique-version-name: function [ file-path ] [
    path-parts: split-path file-path 
    file-parts: split path-parts/2 "." ;-- filename = /1 extension = /2
    filename: copy file-parts/1
    time-stamp: get-timestamp-string 
    filename: rejoin [ filename "-" time-stamp "." file-parts/2 ]
    return to-file reduce [ path-parts/1 filename ]
]

get-text-size: func [ txt [string!] /padded padding [pair!] /font fnt-name  ] [
	txt-pad: either padded [
		padding
	][
		0x0
	]
	either font [
	    l: layout compose [ t1: text (mold txt ) font-name (mold fnt-name) ] 
	][
	    l: layout compose [ t1: text (mold txt ) ]     
	]
	
	return ((size-text t1) + txt-pad)
]

file-modified?: closure [
	track-files: [] [block!]
][
	filename [file!]
][
    split-filename: split-path filename
    local-path: to-local-file split-filename/1
    local-file: to-local-file split-filename/2
    filename: replace/all (replace/all (form filename) "/" "~") " " "_"
	filename-word: to-word filename
	last-stamp: track-files/:filename-word
	call-cmd: rejoin [ {forfiles /P } local-path " /M " local-file { /c "cmd /c echo @file @ftime"} ]
	call-output: copy ""
	call/output call-cmd call-output
	file-stamp: delim-extract/first call-output {" } "^/" 	; This " is a matching quotes so syntax highlighting in my editor works ok

	either last-stamp [
		either last-stamp <> file-stamp [
			track-files/:filename-word: file-stamp
			return true	
		][	
			return false
		]
	][
		insert track-files reduce [ to-set-word filename file-stamp ]
		return false
	]
]
