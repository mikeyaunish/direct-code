Red [ 
    Title: "table-template-support-scripts.red"
]

multi-split: func [
	{returns split text using multiple delimiters}
    series [any-string!]
    dlm [block!] "block of delimiters" /local d res i
][
    foreach d dlm [
        res: split series d
        either (d = last dlm) [
            series: res
        ] [
            series: form res
        ]
    ]
    remove-each i series [i = ""]
    return series
]

get-absolute-offset: function [
	face
][
	offset-adjust: [ 6x6 8x31 6x26 8x51 ] ; items 1 = no-decor, 2 = Win Bar only, 3 = Menu, 4 = Bar + Menu ; 4x4 added as a fix
	adjust-index: 1
	adjustment: 0
	results: face/offset
	target: face/parent
	until [
		results: results + target/offset
		if target/type = 'window [
			if not find target/flags 'no-title [ adjust-index: adjust-index + 1 ]
			if not none? target/menu [ adjust-index: adjust-index + 2 ]
			adjustment: (pick offset-adjust adjust-index)
		]
		target: target/parent
		(target/type = 'screen)
	]
	return (results + adjustment)
]

array-to-text-table: function [
	array [block!] {block of blocks with last value being the index}
][
	longest-item: append/dup copy [] 0 (length? array/1)
	foreach row array [
		repeat item ((length? array/1) - 1) [
			longest-item/:item: max longest-item/:item (length? row/:item)
		]			
	]
	text-blk: copy []
	select-blk: copy []
	foreach row array [
		item-str: copy ""
		repeat i ((length? row) - 1) [
			append item-str pad (pick row i ) longest-item/:i
			if i < ((length? row) - 1) [ append item-str "  " ]
		]
		append/only text-blk (copy item-str)
		append/only select-blk reduce [ item-str (last row)]
	]
	return reduce [ text-blk select-blk ]
]

first-non-block: function [ data [block!]][
	forall data [
	    unless block? data/1 [
	        return index? data
	    ]
	]
]

find-unused-key: function [ 
	{find next unused key in map of negative keys}
	m [map!]
][
	needle: -1
	keys: keys-of m
	while [ find keys needle ][
		needle: needle - 1
	]
	return needle 
]		

series-to-blocks: func [ 
	series block-size
][
	results: copy []
	forskip series block-size [
		new-blk: copy/part series block-size
		append/only results new-blk
	]
	return results
]

forskip: func ['word [word!] length [integer!] body [block!] /local orig][
    unless positive? length [cause-error 'script 'invalid-arg [length]]
    unless series? get word [
        do make error! {forskip expected word argument to refer to a series}
    ]
    orig: get word
    while [any [not tail? get word (set word orig false)]] [
        set/any 'result do body
        set word skip get word length
        get/any 'result
    ]
]

get-widest-column: function [
	{return length of widest column. V3.0}
	blk [block!] 
	column-block [block!]
	/return-string
][
    either ((length? column-block) > 1) [ ; Get width of first field which in a block pair would be the label name
        widest-col: length? to-string (pck: pick (first blk) column-block/1) 
        sec-col: column-block/2
    ][
        widest-col: 0
        sec-col: column-block/1
    ]
    foreach i blk [
        len: length? str: to-valid-string ( pick i sec-col )
        if ( len > widest-col )  [ 
        	widest-col: len 
        	widest-string: copy str 
        ]
    ]
    return either return-string [ widest-string ][ widest-col ]
]

pt: print-table: function [ 
	{prints out a data block in key/value pair. V20}
    'table-blk  {series}
    /width column-width [ integer! block!]
    /max-width max-wide [integer!] {Maximum width of any column.Only applies when /width is not used.}
    /output {returns results rather than printing them}
    /name named-table [string!] {Name of the table displayed before the table itself}
    /columns num-of-cols {defines how many columns contained within each block}
    /column-names col-names-blk [ block! ]
    /col-sequence col-seq [block!]
][ 
    outstring: copy ""
    either output [
        tprin: function [ s ][
            append outstring reduce s
        ]
        tprint: function [ s ][
            append outstring reduce s 
            append outstring newline
        ]        
        
    ][
        tprin:  :prin
        tprint: :print
    ]
    either ((type? table-blk) = word!)[
        table-name: to-word table-blk    
        table-block: get table-blk  
        if none? table-block [ table-block: [] ]
        
    ][
        table-name: "<input block>"
        table-block: copy table-blk
    ]
    if name [
        table-name: copy named-table
    ]
	
	
    tprint rejoin [ "---------------------- Table: '" table-name "' ----------------------"]
    to-block-in-block: function [blk][
        either ((type? blk/1) <> block!)[ reduce [blk] ][ blk ]
    ]
    
    either all [ (not block? table-block/1) columns ] [
        table-block: series-to-blocks table-block num-of-cols
    ][
        table-block: to-block-in-block table-block   
    ]
    
    max-wide: either max-width [ max-wide ][ 60 ]
    width-list: copy []
    pad-size: either width [ column-width ] [ 10 ]

    either columns [
        cols-in-table: num-of-cols
    ][
        cols-in-table: ((length? table-block/1) / 2) ; pull the first record and count how many fields
        col-headings: first table-block    
    ]
    either width [ ;-- This creates user defined width columns
        either ((type? column-width) = block!) [
            width-list: copy column-width
        ][
            loop cols-in-table [
                append width-list column-width
            ]
        ]
    ][ ;-- This creates variable sized columns
        ndx: 1 
        loop cols-in-table [
            either columns [
                wc: get-widest-column table-block reduce [ ndx ]    
                if column-names [
                    wc: max wc ( length? (pick col-names-blk ndx) )
                ]
            ][
                wc: get-widest-column table-block reduce [ (ndx * 2 - 1) (ndx * 2 )] 
            ]
            
            wc: either ((wc + 1) > max-wide)[ max-wide ][ wc ]
            append width-list ( wc + 1 )
            ndx: ndx + 1 
        ]
    ]

    if columns [
        col-headings: copy []
        ndx: 1
        either column-names [
            loop num-of-cols [
                col-name: ( pick col-names-blk ndx )
                head-max-wide: pick width-list ndx
                if (length? col-name ) > head-max-wide [
                    col-name: copy/part col-name ( head-max-wide - 2)
                    append col-name to-char 187 ;-- truncate data to fit
                ]
                append col-headings col-name
                append col-headings "" ;-- col-headings are kept in pairs IE: var-name, value 
                ndx: ndx + 1
            ]        
        ][
            loop num-of-cols [
                append col-headings to-string to-char ( 64 + ndx ) 
                append col-headings ""
                ndx: ndx + 1
            ]
        ]
    ]
    
    ndx: 1
    tprin " "
    col-indices: either col-sequence [ 
    	col-seq 
    ][
    	collect [repeat i ((length? col-headings) / 2 ) [keep i]]
    ]
    
    foreach col-num col-indices [	
    	ndx: col-num 
    	x: pick col-headings (( col-num * 2) - 1)
    	x: to-string x
    	replace/all x "^/" " "
        pad-size: (pick width-list ndx)
        
        tprin [ pad x pad-size ]
    ]
    
    tprint ""
    ndx: 1 
    foreach col-num col-indices [ ;-- print column heading dividers
        pad-size: (pick width-list col-num)
        tprin pad/with (copy " ") pad-size #"─"
    ]
    tprint ""
    foreach entry table-block [ ;-- printing table body 
        ndx: 1
        tprin " "
        skip-count: either columns [ 1 ][ 2 ]
        foreach col-num col-indices [
        	pick-ndx: (col-num * skip-count)
        	y: pick entry pick-ndx
			pad-size: (pick width-list col-num)
            z: copy form y
            if (length? z) > ( pad-size - 1) [
                z: copy/part z (pad-size - 2)
                append z to-char 187 ;-- truncate data to fit
            ]
            tprin rejoin [ pad z pad-size ]
        ]
        tprint ""
    ]
    if output [ return outstring ]
]
	
collect-table-details: function [
	face [object!]
][
	headings: collect [ foreach i face/col-index [
			either i < 0 [
				keep face/virtual-cols/:i/data/1	
			][
				keep trim to-valid-string face/table-data/1/:i
			]
		]
	]
	col-ndx: collect [ foreach i face/col-index [ keep to-valid-string i ] ]
	access: collect [ 
		foreach i face/col-index [
			either find face/read-only-cols i [
				keep "Read Only"
			][
				keep "Read Write"
			]	
		]
	]
	type: collect [ 
		foreach i face/col-index [
			case [ 
				v: face/virtual-cols/:i [
					either (v/type = 'VID) [ keep "Virtual-VID"] [ keep "Virtual" ]
				]
				true [ keep "Data" ]
			]
		]
	]
	sizes: collect [ 
		foreach i face/col-index [
			either v: face/sizes/x/:i [
				keep v
			][
				keep "---"
			]
		]
	]	
	d-type: collect [ 
		foreach i face/col-index [	
			either ct: face/col-type/:i [
				keep ct
			][
				either i < 0 [ keep "Not Needed"][keep "---"]
			]
		]
	]
	ovr-lay: collect [
		foreach i face/col-index [
			case [
				if v: face/code-overlays/:i [
					keep "Code"
				]
				if v: face/vid-overlays/:i [
					keep "VID"
				]
				all [
					v: face/virtual-cols/:i
					v/type = 'vid-repeating
				][
					keep "VID"
				]
				true [
					keep "---"	
				]
			]
		]
	]
	names: copy []
	defaults: copy []
	foreach col-num face/col-index [
		either fnd: find face/col-names col-num [
			append names mold to-valid-string pick face/col-names ((index? fnd) - 1)
		][
			append names "---"
		]
		either def: face/defaults/:col-num [
			either find def "auto-increment" [
				append defaults "auto-incr"
			][
				append defaults "user code"
			]
		][
			append defaults "---"
		]
	]
	
	col-len: length? headings
	results: copy []
	repeat ndx col-len [
		append/only results reduce [
			'COLUMN ndx 
			'COLUMN-HEADING  mold headings/:ndx 'INDEX col-ndx/:ndx 'COL-TYPE type/:ndx
			'DATATYPE d-type/:ndx 'OVERLAY ovr-lay/:ndx 'DATA-ACCESS access/:ndx
			'COL-NAME names/:ndx 'DEFAULT defaults/:ndx
		]		
	]
]

print-table-config: function [ face [object!]][
	tbl-name: either file? face/data [ mold face/data ][ "<Red data Block>" ]
	headers-missing: collect [ 
		foreach col-num face/col-index [
			if all [ 
				col-num > 0
				not face/table-data/1/:col-num
			][
				keep col-num 		
			]
		]
	]
	
    print-table/name (collect-table-details face) tbl-name
	error-msg: copy ""
	if headers-missing <> [] [
		msg-verb: either (length? headers-missing ) > 1 [" are "][ " is " ]
		append error-msg rejoin [
			" - Columns " mold headers-missing " of the first row" msg-verb "missing data." newline
			"^- To fix this, enter the appropriate data into the first row." 
			newline
		]
	]
	if face/frozen = 0x0 [
		append error-msg rejoin [
			" - The Header Row is missing." newline
			"^- To fix this, right click on the first row and select the Menu: 'Row/Freeze' "
			newline
		]
	]
	if (length? face/col-type) <> (length? face/col-index) [
		missing: exclude face/col-index (keys-of face/col-type)
		remove-each v missing [ v < 0 ]
		if (length? missing) > 0 [
			append error-msg rejoin [
				" - Columns: " mold missing " do NOT have a datatype assigned to them."	newline
				"^- To fix this, Right click on those columns missing a datatype" newline
				"^- and select the Menu: 'Column/Type' and then select the appropriate datatype for that column."
				newline
			]
		]
	]
	if ((length? face/col-names) / 2) <> (length? face/col-index) [
		append error-msg rejoin [
			" - Column Names are missing." newline
			"^- To fix this, Right Click on any data cell and select the Menu: 'Column/Set Column Names'"
		]
	]
	either error-msg > "" [
	    print rejoin [ newline "======== INCOMPLETE TABLE CONFIGURATION ========" ]
	    print "------------------------------------------------"
	    print "To complete the table configuration do the following:"
	    print error-msg  
	][
	    print [ newline "======== The Table Configuration is Complete ========" ]
	]
]

between?: func [ val apair ] [
	return either all [ (val >= apair/x) (val <= apair/y) ] [
		true
	][
		false
	]
]

get-max: function [ val [block!] ][
	mx: 0
	foreach i val [ mx: max mx i ]
]

upsert: function [
    {If a value is not found in a series, append it. Returns true if added} 
    series [series!] 
    value
    /only {Append block types as single values}
][
    not none? unless find/:only series :value [insert/:only series :value]
]

source-to-block: function [ source [string!]][
	{Takes a string Red source and returns a code block}
	source: load source 
	if not block? source [ source: to-block mold source ]
	return source
]

get-this-text-size: function [txt [string!] /font fnt-name][
	{returns the size of a single line of text}
	 l: layout compose [t1: text (mold txt)]
	 return size-text t1	
]

get-text-size: func [txt [string!] /font fnt-name][
	{returns the size of multi line text string}
	split-txt: split txt "^/"
	accum: to-point2D 0x0
	foreach line split-txt [
		tsize: get-this-text-size line
		accum/x: max accum/x tsize/x 
		accum/y: accum/y + tsize/y
	]
	return accum 
]

find-in-array-at: func [
	{return values found in an array block or block of blocks. V2.0}
    blk [any-type!]
    at-loc [integer!] "skip amount into each element of the array"
    find-this
    /with-index
    /within "will search within a block"
    /every
    /last /local collected array-len array ndx real-index finder i
][
    collected: copy []
    if ((array-len: length? blk) < 1) [
        return false
    ]
    either last [
        array: copy blk
        reverse array
    ] [
        array: blk
    ]
    ndx: 1
    real-index: func [index] [either last [(array-len - (index - 1))] [index]]
    either within [
        finder: func [to-find] [
            find (pick i at-loc) to-find
        ]
    ] [
        finder: func [to-find] [
            to-find = (pick i at-loc)
        ]
    ]
    foreach i array [
        if (finder find-this) [
            either with-index [
                either every [
                    append/only collected reduce [i (real-index ndx)]
                ] [
                    return reduce [i (real-index ndx)]
                ]
            ] [
                either every [
                    append/only collected i
                ] [
                    return i
                ]
            ]
        ]
        ndx: ndx + 1
    ]
    if every [
        either ((length? collected) = 0) [
            return false
        ] [
            return collected
        ]
    ]
    return false
]

deep-copy: function [value [any-type!]] [ 
	{Return a deep copy of an object that contains some combination of maps,series, values or blocks}
    case [
        object? :value [
            specs: make block! []
            words: words-of :value
            foreach word words [
                if all [word? :word not none? :word] [
                    val: get/any word :value
                    append specs to set-word! word
            		append/only specs deep-copy :val 
                ]
            ]
            make object! specs
        ]
        map? :value [
            new-map: make map! []
            foreach [key val] body-of :value [
                if not none? :key [
                    put new-map :key deep-copy :val
                ]
            ]
            new-map
        ]
        block? :value [
            result: copy []
            foreach item :value [
                appended: deep-copy item
                append/only result appended
            ]
            result
        ]
        series? :value [
            copy :value
        ]
        true [
            :value
        ]
    ]
]

remove-punctuation: function [
    "Remove all punctuation characters from a string"
    text [string!] "Input string to process"
][
    punctuation: charset {.,;:!?'"()[]{}~-_+=<>\/|@#$%^&*`}
    parse text [any [remove punctuation | skip]]
    text
]

to-kebab-names: function [
	field-block [block!] {return array of red type names from an array of blocks containing <num> and <header-string>}
][
	fld-blk: copy/deep field-block
	collect [
		foreach item fld-blk [ ;-- ie: [ 1 "id" ]
			s: trim lowercase item/2
			remove-punctuation s
    	    printable-plus-space: charset [#"!" - #"~"]  
    		parse s [any [some printable-plus-space | change skip "-"]]			
			keep s
		]
	]
]

view-table: function [ 
	table-data [block!]
	/no-header
][
	sizes: collect [
		repeat col-num (length? table-data/1) [ 
			keep get-this-text-size get-widest-column/return-string table-data reduce [ col-num ]
		]			
	]
	opt-blk: either no-header [ [] ] [ [config: [frozen-rows:[1]]]  ]
	view compose/deep [
		title "view-table"
		vt-tbl: table 700x200 data table-data 
			options [ (opt-blk) ]
			b: box 0x0 
			on-created [
				repeat ndx (length? table-data/1)[
					vt-tbl/sizes/x/:ndx: to-integer sizes/:ndx/x + 5 
				]
				vt-tbl/actors/refresh-view vt-tbl
			]
	]
]

split-filename: func [
    {returns a block containing [ <base-name-of-file> <file-extension> ] }
    filename [file!]
][
    return reduce [
        to-string first split (second (split-path filename)) "."
        to-string second split (second (split-path filename)) "."
    ]
]

expand-range-block: func [blk [block!] /local lo hi][
    parse blk [set lo pair! skip set hi pair!]
    expand-pair-range (min lo hi) (max lo hi)
]

expand-pair-range: func [lo [pair!] hi [pair!] /local result x y][
    result: copy []
    x: lo/x
    while [x <= hi/x] [
        y: lo/y
        while [y <= hi/y] [
            append result as-pair x y
            y: y + 1
        ]
        x: x + 1
    ]
    result
]
