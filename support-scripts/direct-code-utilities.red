Red [
	Title: "direct-code-utilities.red"
	Comment: "Imported from: <root-path>%experiments/direct-code-utilities/direct-code-utilities.red"
]
count-newlines: function [
    value
] [
    length? split value #"^/"
] 
verify-type: func [
    {Verifies if the value supplied can be considered a valid datatype} 
    input-type [datatype! word!] "datatype or generic lit-word like: 'color" 
    value [any-type!]
] [
    retry-messages: [
        tuple 
        "<num>.<num>.<num>.^/Example: 100.20.50" 
        pair 
        "<num>x<num>.^/Example: 50x90" 
        color 
        {RRR.GGG.BBB.TTT . Where RRR = (Red Value) , GGG = (Green Value) , BBB = (Blue Value) , TTT = (Tranparent Value). Transparent value is optional.  All values are within the range of: 0 to 255 Example: 200.100.0.128 } 
        size 
        "<width-value>x<height-value>.^/Example: 50x90" 
        file 
        {%/<drive>/<path>/<filename>. Example: %/C/Red/my-script.red}
    ] 
    custom-types: [
        color tuple! 
        size pair!
    ] 
    orig-input-type: input-type 
    if word? input-type [
        if not input-type: reduce select custom-types input-type [
            exit
        ]
    ] 
    msg-block: compose ["ERROR trying to convert " mold target " to a " mold orig-input-type {  Please re-enter your data to match this format: }] 
    append msg-block select retry-messages to-word to-string orig-input-type 
    datatype-check: get to-word rejoin [to-string input-type "?"] 
    results: validate value [
        if datatype-check to-valid input-type target [target]
    ] msg-block
] 
clear-file: does [
    close-object-editor/all-open 
    setup-code/text: copy "" 
    vid-code/text: copy "" 
    setup-code-undoer/set-initial-text "" 
    vid-code-undoer/set-initial-text "" 
    run-and-save "clear-file" 
    show-insert-tool/refresh
] 
pe: print-each: function [
    {print-each item in a block or string with item numbers (v3)} 
    'value 
    /output "return a value rather than print it" 
    /deep {show details of all sub-blocks within the main block} 
    /depth depth-label [string!] "Used internally by the function for recursion" 
    /columns num-of-cols [integer!] 
    /width wide [integer!] "Used with /columns to set column width" 
    /name display-name [string!]
] [
    either name [
        value-name: rejoin ["'" display-name "' ="]
    ] [
        either ((type? value) = word!) [
            value-name: rejoin ["'" to-string to-word value "' ="] 
            value: get value
        ] [
            value-name: "'<value passed to function>' ="
        ]
    ] 
    pad-size: either width [wide] [0] 
    results: copy "" 
    either depth [
        depth-num: rejoin [to-string depth-label "."]
    ] [
        depth-num: copy "" 
        append results value-name
    ] 
    index: 1 
    item-label: rejoin [depth-num to-string index] 
    col-index: 1 
    foreach item value [
        either all [
            (block? item) 
            deep
        ] [
            append results rejoin [newline item-label ") ----------"] 
            append results print-each/depth/output/deep (copy item) item-label
        ] [
            either columns [
                either col-index = 1 [
                    append results rejoin [
                        "^/  " 
                        pad/left rejoin [item-label ") "] 5 
                        pad mold item pad-size
                    ]
                ] [
                    append results rejoin [
                        " " 
                        pad mold item pad-size
                    ]
                ] 
                col-index: col-index + 1 
                if col-index > num-of-cols [
                    col-index: 1
                ]
            ] [
                append results rejoin [
                    "^/  " 
                    pad/left rejoin [item-label ") "] 5 
                    mold item
                ]
            ]
        ] 
        index: index + 1 
        item-label: rejoin [depth-num to-string index]
    ] 
    if not depth [
        append results "^/"
    ] 
    if output [
        return results
    ] 
    print results 
] 
print-chars: function [
    val 
    /output
] [
    if output [
        return print-each/columns/width/output val 10 7
    ] 
    print-each/columns/width val 10 7
] 
if-empty-block-to-none: function [value] [
    if value = [] [return none] 
    return value
] 
if-word-to-datatype: function [value] [
    if value = 'true [return true] 
    if value = 'false [return false] 
    if value = 'none [return none] 
    return value
] 
between?: func [val apair] [
    return either all [(val >= apair/x) (val <= apair/y)] [
        true
    ] [
        false
    ]
] 
all-whitespace?: function [
    series
] [
    foreach c series [
        if not is-whitespace? c [
            return false
        ]
    ] 
    return true
] 
is-whitespace?: function [
    {a character set containing only the in-line whitespace characters space (U+0020) and tab (U+0009).} 
    c [char!]
] [
    any [
        (c == #" ") 
        (c == #"^-") 
        (c == #"^M") 
        (c == #"^/") 
        (c == #"^K") 
        (c == #"^L")
    ]
] 
set 'last-printable function [
    val [string!]
] [
    value: copy val 
    reverse value 
    if fp: first-printable value [
        return ((length? val) - fp + 1)
    ] 
    return none
] 
set 'first-printable function [
    val [string!]
] [
    index: 1 
    foreach c val [
        if not is-whitespace? c [
            return index
        ] 
        index: index + 1
    ] 
    return none
] 
set 'to-valid function [
    datatype [datatype!] 
    val [any-type!]
] [
    either ((scan val) = datatype) [
        return load val
    ] [
        return none
    ]
] 
get-indent-chars: function [
    {get the characters that indent the beginning of the string line described} 
    value [string!] 
    position [integer!]
] [
    prev-newline: char-index?/back value position #"^/" 
    first-char: first-printable (skip value prev-newline) 
    return copy/part (skip value prev-newline) (first-char - 1)
] 
closure: func [
    vars [block!] "Values to close over, in spec block format" 
    spec [block!] "Function spec for closure func" 
    body [block!] "Body of closure function- vars will be available"
] [
    func spec compose [(bind body context vars)]
] 
get-previous-word: function [
    str [string!] 
    ndx [integer!] 
    /with delims
] [
    pos: ndx 
    word-delims: either with [
        delims
    ] [
        "^/^- /"
    ] 
    curr-char: pick str (pos - 1) 
    while [
        all [
            (pos > 0) 
            (not (find word-delims curr-char))
        ]
    ] [
        pos: pos - 1 
        curr-char: pick str pos
    ] 
    return copy/part (skip str pos) (ndx - pos)
] 
make-array: function [
    default-val 
    array-length
] [
    temp: make block! [] array-length 
    append/only/dup temp copy [] array-length 
    return temp
] 
comment 
{^M^/        ^-Title: "File tools"^M^/        ^-Author: "Boleslav Březovský"^M^/        } 
match: func [
    {Match string to given wildcard pattern (supports ? and *)} 
    value [any-string!] 
    pattern [any-string!] 
    /local forward
] [
    forward: func [] [
        value: next value 
        pattern: next pattern
    ] 
    value: to string! value 
    pattern: to string! pattern 
    until [
        switch/default pattern/1 [
            #"?" [forward] 
            #"*" [
                unless value: find value first pattern: next pattern [
                    return false
                ]
            ]
        ] [
            either equal? value/1 pattern/1 [forward] [return false]
        ] 
        tail? pattern
    ] 
    unless empty? value [return false] 
    true
] 
foreach-file: func [
    "Evaluate body for each file in a path" 
    'file [word!] 
    path [file!] 
    body [block!] 
    /with "Wildcard based pattern file has to confort to" 
    pattern [any-string!] 
    /local files f
] [
    files: read path 
    foreach f files [
        f: rejoin [path f] 
        either dir? f [
            either with [
                foreach-file/with :file f body pattern
            ] [
                foreach-file :file f body
            ]
        ] [
            if any [
                not with 
                all [with match second split-path f pattern]
            ] [
                set :file f 
                do body
            ]
        ]
    ]
] 
set 'make-style-global function [
    'vid-object "The Style object" 
    source-code
] [
    style-parents: get-style-parents (to-string vid-object) source-code 
    foreach style style-parents [
        set (to-set-word style) get-object-from-source (to-string style) source-code
    ]
] 
set 'get-object-style function [
    source-code
] [
    return first parse to-block source-code [
        collect [any [set-word! keep word! | skip]]
    ]
] 
set 'get-style-parents function [
    {Get all styles and parent styles for given source code} 
    style-name [string!] 
    source-code [string!] 
    /root
] [
    style-parents: copy [] 
    insert style-parents (to-word style-name) 
    object-source: get-object-source (to-string style-name) source-code 
    style-name: get-object-style object-source 
    if style-name = none [
        return none
    ] 
    while [not stock-style? style-name] [
        insert style-parents style-name 
        object-source: get-object-source (to-string style-name) source-code 
        if not object-source [
            break
        ] 
        style-name: get-object-style object-source 
    ] 
    if root [
        insert style-parents style-name
    ] 
    return style-parents
] 
set 'whitespace-edge? function [
    "finds edge of whitespace (excluding newline)" 
    source-code [string!] 
    position [integer!] "location to start" 
    /reverse
] [
    if position = 0 [return 1] 
    if position > len: length? source-code [return len] 
    index: position 
    op: either reverse [:-] [:+] 
    got-one: pick source-code index 
    if not all [
        (is-whitespace? got-one) 
        (got-one <> #"^/")
    ] [
        return index
    ] 
    while [
        all [
            (is-whitespace? got-one) 
            (got-one <> #"^/")
        ]
    ] [
        index: index op 1 
        if not got-one: pick source-code index [break]
    ] 
    op: either reverse [:+] [:-] 
    return (index op 1)
] 
set 'get-object-source function [
    object-name [string!] 
    source-code [string!] 
    /position 
    /whitespace {include pre and post whitespace with /position.Result pair appended to result.}
] [
    if not (v-src: second (query-vid-object source-code object-name [])) [
        return false
    ] 
    last-item: length? v-src 
    last-char: pick source-code v-src/:last-item/token/y 
    y-correction: either (is-whitespace? any [last-char #" "]) [-1] [0] 
    obj-position: to-pair reduce [v-src/1/token/x (v-src/:last-item/token/y + y-correction)] 
    results: copy/part (skip source-code (obj-position/x - 1)) (obj-position/y - obj-position/x + 1) 
    if position [
        results: reduce [results] 
        append results obj-position 
        if whitespace [
            left-edge: whitespace-edge?/reverse source-code (obj-position/x - 1) 
            right-edge: whitespace-edge? source-code (obj-position/y + 1) 
            append results to-pair reduce [left-edge right-edge]
        ]
    ] 
    return results
] 
set 'safe-select function [
    object [object! block! word! lit-word!] 
    path [word! lit-word!] "lit-word! only to be used in tail of path"
] [
    if word? object [
    ] 
    pick-with: either (lit-word? path) [
        if any [(word? object) (lit-word? object)] [object: to-block object] 
        :find
    ] [
        :select
    ] 
    return either ((got: pick-with object path) = none) [
        none
    ] [
        either all [(word? :got) (lit-word? path)] [
            to-block got
        ] [
            got
        ]
    ]
] 
set 'select-in-object function [
    'obj [object! lit-word! object! word!] 
    the-path [word! block! lit-word!] {lit-word! only to be used as the tail in a block of path words}
] [
    obj: get obj 
    either (block? the-path) [
        results: obj 
        foreach wrd the-path [
            if ((results: safe-select results wrd) = none) [
                return none
            ]
        ] 
        return results
    ] [
        return safe-select obj the-path
    ]
] 
find-all: function [
    "Find all occurrences of a value in a series." 
    'series [word!] 
    value
] [
    either not series? orig: get series [none] [
        collect [
            while [any [set series find get series :value (set series orig false)]] [
                keep/only get series 
                set series next get series
            ]
        ]
    ]
] 
string-select: function [
    haystack [string!] "String to search through" 
    needle [string!] "String to select on. Next word will be returned"
] [
    select (delim-split haystack ["^/" " " "^-"]) needle
] 
find-path-in-array: function [
    array [block!] "the array block" 
    path [block!] "block of words defining path"
] [
    ndx: 1 
    foreach item array [
        if item = to-path path [
            return reduce [item ndx]
        ] 
        ndx: ndx + 1
    ] 
    return false
] 
delim-split: function [
    {Break a string series into pieces using one or more provided delimiter(s)} 
    series [any-string!] dlm [string! char! bitset! block!] 
    /local s num new-dlm
] [
    if (type? dlm = block!) [
        new-dlm: copy [] 
        foreach i dlm [
            append new-dlm reduce [i '|]
        ] 
        remove back tail new-dlm 
        dlm: copy new-dlm
    ] 
    num: either string? dlm [length? dlm] [1] 
    results: parse series [collect any [copy s [to [dlm | end]] keep (s) num skip [end keep (copy "") | none]]] 
    remove-each i results [i = ""] 
    return results
] 
show-current-folder: does [
    show-folder what-dir
] 
show-folder: function [
    cur-dir [file!]
] [
    cur-dir: to-local-file cur-dir 
    split-slash: split cur-dir "\" 
    drive-letter: rejoin [split-slash/1 "\"] 
    batch-script: copy drive-letter 
    append batch-script rejoin [newline {explorer.exe "} cur-dir {"}] 
    write %show-current-folder.bat batch-script 
    call/wait "show-current-folder.bat" 
    delete %show-current-folder.bat
] 
to-valid-font-size: func [v] [
    return either (v > 0) [v] [
        request-message rejoin [v { is not a valid font size. Making the font size '9'}] 
        9
    ]
] 
to-valid-file: func [val] [
    if file? val [
        return val
    ] 
    if ((first val) = #"%") [remove val] 
    either find val {"} [
        return to-file load val
    ] [
        return to-file val
    ]
] 
de-block-string: function [s] [
    r: trim copy s 
    if ((first r) = #"[") [remove r] 
    if ((last r) = #"]") [remove back tail r] 
    return r
] 
de-quote-string: function [s] [
    r: trim copy s 
    if ((first r) = #"^"") [remove r] 
    if ((last r) = #"^"") [remove back tail r] 
    return r
] 
de-curly-string: function [s] [
    r: trim copy s 
    if ((first r) = #"{") [remove r] 
    if ((last r) = #"}") [remove back tail r] 
    return r
] 
string-to-valid-type: function [
    val [string!]
] [
    scan-res: scan/next val 
    if not scan-res [return ""] 
    val-type: first scan-res 
    switch (to-string val-type) [
        "word" [
            if val = "true" [return true] 
            if val = "false" [return false]
        ] 
        "block" [
            val: de-block-string val
        ] 
        "date" [
            return load val
        ] 
        "error" [
            request-message/size rejoin [{Unable to turn the string below into a valid data format.^/} form val] 600x400 
            return ""
        ]
    ] 
    return to val-type val
] 
to-valid-set-word: function [val] [
    tmp-val: copy val 
    trim/with tmp-val ":" 
    return append tmp-val ":"
] 
find-path-in-array: function [
    array [block!] "the array block" 
    path [block!] "block of words defining path"
] [
    ndx: 1 
    foreach item array [
        if item = to-path path [
            return reduce [item ndx]
        ] 
        ndx: ndx + 1
    ] 
    return false
] 
request-a-file: func [
    current-file [file! string!] {current file - if there is one, otherwise ""} 
    message [string!] "Message to display" 
    prompt [string!] "Prompt that appears in front of field" 
    /skip-button
] [
    ret-val: copy "" 
    return-val: func [/cancel] [
        either cancel [
            ret-val: none
        ] [
            ret-val: to-red-file any [file-field/text ""]
        ] 
        unview/only rre
    ] 
    either skip-button [
        skip-btn: [button "SKIP" 100x24 [return-val]]
    ] [
        skip-btn: [button 0x0 hidden]
    ] 
    rre: layout compose [
        title "Select a File" 
        across 
        space 0x4 
        text "" 120x24 
        text message 400x48 
        return 
        text prompt right 120x24 font-size 10 space 0x8 
        file-field: field 400x24 [
            return-val
        ] 
        space 2x8 
        exec-pick: button "^^" 24x24 [
            if (filename: request-file) [
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
get-set-words: func [in-blk [block!]] [
    ret-blk: copy [] 
    parse in-blk [any [set sw set-word! (append ret-blk sw) | skip]] 
    return ret-blk
] 
mold-no-quote: func [s] [
    remove head (remove back tail (mold s))
] 
unset-uid-vars: function [
    uid [string!]
] [
    curr-words: get-all-current-words/only 
    curr-words: skip curr-words 600 
    wrd-count: 1 
    foreach wrd curr-words [
        if (find (to-string wrd) uid) [
            wrd-count: wrd-count + 1 
            unset wrd
        ]
    ]
] 
get-all-current-words: function [
    "return all system words and types" 
    /only "return only words without types"
] [
    b: words-of system/words 
    reduce-block: copy either only [
        [:w]
    ] [
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
to-safe-pair: function [
    value [string! pair! point2D!]
] [
    if (attempt-result: attempt [to-pair value]) [
        return attempt-result
    ] 
    if attempt-result: attempt [
        scan-type: scan value 
        to-pair to :scan-type value
    ] [
        return attempt-result
    ] 
    return 0x0
] 
to-safe-integer: function [
    value
] [
    if (attempt-result: attempt [to-integer value]) [
        return attempt-result
    ] 
    if attempt-result: attempt [
        scan-type: scan value 
        to-integer to :scan-type value
    ] [
        return attempt-result
    ] 
    return 0
] 
to-safe-tuple: function [v] [
    either error? try/all [
        res: to-tuple v 
        true
    ] [
        return 128.128.128
    ] [
        return res
    ]
] 
to-safe-string: function [s] [
    return either (s = none) [
        ""
    ] [
        to-string s
    ]
] 
if-single-to-block: function [
    v [any-type!] 
    /block-in-block
] [
    blk: copy [] 
    ret-val: either [(type? v) <> block!] [
        to-block v
    ] [
        v
    ] 
    if block-in-block [
        if not block? first v [
            ret-val: append/only blk ret-val
        ]
    ] 
    return ret-val
] 
string-to-date: function [
    {converts a DD-MMM-YYYY string into a date! datatype} 
    s [string!]
] [
    s: split s "-" 
    return to-date reduce [
        (to-integer s/1) 
        (index? find ["Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"] s/2) 
        (to-integer s/3)
    ]
] 
load-importable: function [
    source-file [file!]
] [
    do select (select (load source-file) 'setup) 'importable
] 
refine-function: function [
    {Refines a function with the specified refinements.} 
    'f "The function" 
    r [any-block!] "refinements block" 
    /args a [any-block!] {argument block that match function args and refinement values}
] 
[
    if args [
        df: refine-function :f r 
        to-do: compose reduce [df] 
        foreach i a [
            append/only to-do i
        ] 
        return to-do
    ] 
    p: to-path head insert/only head copy r f 
    return :p
] 
fix-dt: fix-datatype: function [
    "fix all datatype values in an array" 
    array [block!]
] [
    datatype-list: [
        datatype! unset! none! logic! block! 
        paren! string! file! url! char! 
        integer! float! word! set-word! lit-word! 
        get-word! refinement! issue! native! action! 
        op! function! path! lit-path! set-path! 
        get-path! routine! bitset! point! object! 
        typeset! error! vector! hash! pair! 
        percent! tuple! map! binary! time! 
        handle! date! port! money! ref! 
        tag! email! image! event!
    ] 
    x: 0 
    loop (length? array) [
        x: x + 1 
        val: pick array x 
        either block? val [
            fix-datatype val
        ] [
            if all [((type? val) = word!) (find datatype-list val)] [
                set (to-path reduce ['array x]) reduce val
            ]
        ]
    ] 
    return array
] 
get-panel-styles: function [panel] [
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
offset-to-line-num: func [
    text 
    the-offset 
    /vid 
    /local line-num
] [
    line-num: length? split (copy/part text the-offset) "^/" 
    return either vid [
        setup-code-length: index? find (read/lines dc-filename) vid-code-marker 
        setup-code-length + line-num + 1
    ] [
        line-num
    ]
] 
get-assert-parts: func [blk [block!]] [
    ops: ['= | '== | '<> | '> | '< | '>= | '<= | '=?] 
    parse blk [
        copy frt-part to ops 
        rem-part: (op-part: rem-part/1) 
        skip sec-part:
    ] 
    return reduce [frt-part op-part sec-part]
] 
copy-file: func [
    source [file! url!] 
    destination [file!]
] [
    write/binary destination read/binary source
] 
char-index?: function [
    {Get character index forward or back relative to offset given. Defaults to forward} 
    series 
    offset 
    needle [char!] 
    /back
] [
    reverse: either back [true] [false] 
    either fnd: find/:reverse (skip series offset) needle [
        return index? fnd
    ] [
        return 0
    ]
] 
string-to-block: function [
    s [string!] 
    /no-indent
] [
    if s = none! [return []] 
    lines: split s "^/" 
    res: copy "" 
    if ((trim (copy lines/1)) = "") [
        lines: skip lines 1
    ] 
    foreach l lines [
        either no-indent [
            append res rejoin [l "^/"]
        ] [
            append res rejoin ["    " l "^/"]
        ]
    ] 
    remove back tail res 
    post-fix: either ((last res) = #"^/") ["]"] ["^/]"] 
    return rejoin ["[^/" res post-fix]
] 
un-block-string: function [
    {removes head and tail square brackets (including newlines) from a multi-line string} 
    val [string!] 
    /only "Exclude head and tail newlines"
] [
    trim/head (trim/tail val) 
    if all [
        ((first val) = #"[") 
        ((last val) = #"]")
    ] [
        remove val 
        remove back tail val
    ] 
    if not only [
        if ((first val) = #"^/") [remove val] 
        if ((last val) = #"^/") [remove back tail val]
    ] 
    return val
] 
get-object-name: func [this-obj] [
    all-vid-names: get-set-words to-block vid-code/text 
    foreach vid-name all-vid-names [
        if all [
            (value? to-word vid-name) 
            (this-obj == (get to-word vid-name))
        ] [
            return to-string vid-name
        ]
    ] 
    return "*unusable-no-name*"
] 
string-is-pair?: function [
    str [string!] "string to test"
] [
    nums: charset "-0123456789" 
    parse str [any nums "x" any nums]
] 
string-is-word?: function [
    str [string!] "string to test"
] [
    if all [
        (attempt [aword: to-word str]) 
        ((mold aword) = str)
    ] [
        return true
    ] 
    return false
] 
all-to-logic: function [v] [
    return switch/default (to-word type? v) [
        integer! [
            switch/default v [
                0 [false] 
                1 [true]
            ] [
                true
            ]
        ] 
        word! [
            switch/default v [
                true [true] 
                false [false]
            ] [
                false
            ]
        ] 
        string! [
            switch/default v [
                "true" [true] 
                "false" [false] 
                "" [false]
            ] [
                true
            ]
        ] 
        file! [
            switch/default v [
                %"" [false]
            ] [
                true
            ]
        ]
    ] [
        to-logic v
    ]
] 
compare-objects: func ['a 'b /show-diffs] [
    a: get a 
    b: get b 
    diff-list: copy [] 
    foreach [word val] body-of a [
        either any [(any-function? :val) ((type? val) = object!)] [] [
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
    left/offset/y: to integer! right/offset/y - (divide (left/size/y - right/size/y) 2) 
    left/offset/x: to integer! right/offset/x - (divide (left/size/x - right/size/x) 2)
] 
get-uid: does [
    return replace/all replace/all (to-string now/time/precise) ":" "" "." ""
] 
find-in-array-with: function [
    block-array [block!] 
    with-word [word!] 
    value [any-type!]
] [
    foreach block-item block-array [
        if (select block-item with-word) = value [
            return block-item
        ]
    ] 
    return none
] 
find-in-array-at: function [
    blk [any-type!] 
    at-loc [integer!] 
    find-this 
    /with-index 
    /every 
    /last
] [
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
    foreach i array [
        if find-this = (pick i at-loc) [
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
pick-deep: function [val index [block!]] [
    res: val 
    foreach i index [
        res: pick res i
    ] 
    return res
] 
forskip: function ['word [word!] length [integer!] body [block!]] [
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
search-in-block-at: function [
    blk [any-type!] 
    at-loc [block!] { 1st integer = skip amount, 2nd integer and onwards determine pick offset } 
    find-this 
    /with-index 
    /every 
    /find-in 
    /local ndx i collected
] [
    prin "" 
    collected: copy [] 
    if ((length? blk) < 1) [
        return false
    ] 
    ndx: 1 
    pick-block: copy skip at-loc 1 
    either find-in [
        comparator: [find i find-this]
    ] [
        comparator: [find-this = i]
    ] 
    forskip blk at-loc/1 [
        (i: pick-deep blk pick-block) 
        if do comparator [
            either with-index [
                either every [
                    append/only collected reduce [i ndx]
                ] [
                    append/only collected reduce [i ndx] 
                    break
                ]
            ] [
                either every [
                    append/only collected i
                ] [
                    append/only collected i 
                    break
                ]
            ]
        ] 
        ndx: ndx + 1
    ] 
    either collected = [] [
        return false
    ] [
        return collected
    ]
] 
compare-object-contents: function ['a 'b /return-diffs] [
    a: get a 
    b: get b 
    diff-list: copy [] 
    foreach [word val] body-of a [
        either any [(any-function? :val) ((type? val) = object!)] [] [
            either equal? :val get in b reduce (to-lit-word word) [] [
                if return-diffs [
                    append diff-list to-word word
                ]
            ]
        ]
    ] 
    return diff-list
] 
requester-window-escape: func [code req-obj-name /options win-opts] [
    win-opts: any [win-opts (copy [])] 
    return compose/deep [
        actors: object [
            on-key: func [face event] [
                switch event/key [
                    #"^[" [(code)]
                ]
            ] 
            on-close: func [face event] [
                (code)
            ] 
            on-menu: func [face [object!] event [event!]] [
                event-picked: to-string event/picked 
                handler-obj-name: either face/extra/current-object-name = "" [
                    (req-obj-name)
                ] [
                    face/extra/current-object-name
                ] 
                voe-menu-handler handler-obj-name event-picked
            ]
        ] 
        (win-opts)
    ]
] 
spaces: [any [" " | "^/" | "^-"]] 
point-in-triangle?: function [
    pt [pair!] 
    v1 [pair!] 
    v2 [pair!] 
    v3 [pair!]
] [
    sign-of-point: function [p1 p2 p3] [
        return (((p1/x - p3/x) * (p2/y - p3/y)) - ((p2/x - p3/x) * (p1/y - p3/y)))
    ] 
    d1: sign-of-point pt v1 v2 
    d2: sign-of-point pt v2 v3 
    d3: sign-of-point pt v3 v1 
    has-neg: any [(d1 < 0) (d2 < 0) (d3 < 0)] 
    has-pos: any [(d1 > 0) (d2 > 0) (d3 > 0)] 
    return not all [(has-neg) (has-pos)]
] 
which-different: func [set1 set2 entry-size] [
    d: difference set1 set2 
    results: copy [] 
    loop-cnt: ((length? d) / entry-size) 
    i: 0 
    loop loop-cnt [
        entry: copy/part (skip d (i * entry-size)) entry-size 
        i: i + 1 
        if fnd: find set1 entry [
            append/only results reduce [1 entry]
        ] 
        if fnd: find set2 entry [
            append/only results reduce [2 entry]
        ]
    ] 
    return results
] 
get-next-version-name: function [file-path] [
    file-path-split: split-path file-path 
    file-name-split: split (to-string file-path-split/2) "." 
    just-name: file-name-split/1 
    file-ext: file-name-split/2 
    ndx-pos: length? just-name 
    foreach i (reverse copy just-name) [
        either (not find "0123456789" to-string i) [
            name-part: copy/part just-name ndx-pos 
            num-part: copy (skip just-name ndx-pos) 
            either (num-part = "") [
                num-part: 1
            ] [
                num-part: to-string ((to-integer num-part) + 1)
            ] 
            break
        ] [
            ndx-pos: ndx-pos - 1
        ]
    ] 
    return to-file rejoin [file-path-split/1 name-part num-part "." file-ext]
] 
get-timestamp-string: does [
    now-time: now/precise 
    now-time: rejoin [now-time/date "-" now-time/hour "-" now-time/minute "-" to-string to-time now-time/second] 
    replace/all replace/all (replace/all now-time "/" "-") ":" "-" "." "-" 
    return now-time
] 
get-unique-version-name: function [file-path] [
    path-parts: split-path file-path 
    file-parts: split path-parts/2 "." 
    filename: copy file-parts/1 
    time-stamp: get-timestamp-string 
    filename: rejoin [filename "-" time-stamp "." file-parts/2] 
    return to-file reduce [path-parts/1 filename]
] 
get-text-size: func [txt [string!] /padded padding [pair!] /font fnt-name] [
    txt-pad: either padded [
        padding
    ] [
        0x0
    ] 
    either font [
        l: layout compose [t1: text (mold txt) font-name (mold fnt-name)]
    ] [
        l: layout compose [t1: text (mold txt)]
    ] 
    return ((size-text t1) + txt-pad)
] 
file-modified?: closure [
    track-files: [] [block!]
] [
    filename [file!]
] [
    split-filename: split-path filename 
    local-path: to-local-file split-filename/1 
    local-file: to-local-file split-filename/2 
    filename: replace/all (replace/all (form filename) "/" "~") " " "_" 
    filename-word: to-word filename 
    last-stamp: track-files/:filename-word 
    call-cmd: rejoin ["forfiles /P " local-path " /M " local-file { /c "cmd /c echo @file @ftime"}] 
    call-output: copy "" 
    call/output call-cmd call-output 
    file-stamp: delim-extract/first call-output {" } "^/" 
    either last-stamp [
        either last-stamp <> file-stamp [
            track-files/:filename-word: file-stamp 
            return true
        ] [
            return false
        ]
    ] [
        insert track-files reduce [to-set-word filename file-stamp] 
        return false
    ]
] 
unset-object: function [object [word!]] [
    set (to-set-word object) "" 
    unset (to-word object)
] 
get-voe-window-uid: function [
    object-name
] [
    window-name: rejoin ["--voe-window-" object-name] 
    if value? (to-word window-name) [
        return (get to-path reduce [to-word window-name 'extra 'target-object-name])
    ] 
    return none
] 
get-voe-window-name: function [
    object-name
] [
    return to-word rejoin ["--voe-window-" object-name]
] 
get-voe-window-status: function [
    object-name
] [
    window-name: get-voe-window-name object-name 
    if value? window-name 
    [
        if (win-uid: get-voe-window-uid object-name) [
            return (get to-word rejoin ["requester-completed?" win-uid])
        ]
    ] 
    return false
] 
delim-extract: func [
    {returns a block of every string found that is surrounded by defined delimeters} 
    source-str [string!] "Text string to extract from." 
    left-delim [string!] {Text string delimiting the left side of the desired string.} 
    right-delim [string!] {Text string delimiting the right side of the desired string.} 
    /include-delimiters "Returned extractions will include the delimiters" 
    /use-head "Head of string is used as left delimiter" 
    /first "Return the first match found only" 
    /pairs-only {Return only fully matched pairs of delimiters. Left and right delimiter need to be the same.} 
    /local tags tag i j paired-tags
] [
    tag: "" 
    tags: copy [] 
    if use-head [
        either include-delimiters [
            parse source-str [copy tag thru right-delim] 
            insert head tag left-delim
        ] [
            parse source-str [copy tag to right-delim]
        ] 
        append tags tag
    ] 
    either include-delimiters [
        parse source-str [some [[thru left-delim copy tag to right-delim] (append tags rejoin [left-delim tag right-delim])]]
    ] [
        parse source-str [some [[thru left-delim copy tag to right-delim] (append tags tag)]]
    ] 
    either first [
        either ((length? tags) = 0) [
            return none
        ] [
            return tags/1
        ]
    ] [
        either all [pairs-only (left-delim = right-delim)] [
            paired-tags: copy [] 
            foreach [i j] tags [
                append paired-tags i
            ] 
            return paired-tags
        ] [
            return tags
        ]
    ]
]
