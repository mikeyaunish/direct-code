Red [
	Title: "direct-code-utilities.red"
	Comment: "Imported from: <root-path>%experiments/direct-code-utilities/direct-code-utilities.red"
]
closure: func [
    vars [block!] "Values to close over, in spec block format"
    spec [block!] "Function spec for closure func"
    body [block!] "Body of closure function- vars will be available"
] [
    func spec compose [(bind body context vars)]
]
chunk-string: func [
    {Divides a long string into defined length using the space character as the delimiter}
    value [string!] "Source string"
    length [integer!] "Limits line length"
    /line-separator separator [string! char!] "Changes the default separator from newline"
] [
    if ((length? value) <= length) [
        return value
    ]
    newline-sep: either line-separator [
        separator
    ] [
        newline
    ]
    str-offset: 0
    last-fnd-offset: 0
    until [
        str-offset: str-offset + length
        read-pos: skip value str-offset
        if read-pos = "" [break]
        if any [
            (space-fnd: find/reverse read-pos " ")
            (space-fnd: find/reverse read-pos newline-sep)
            (none = find/reverse read-pos " ")
        ] [
            fnd-offset: either space-fnd [index? space-fnd] [0]
            either fnd-offset <= last-fnd-offset [
                insert (skip value ((index? read-pos) - 1)) newline-sep
                str-offset: index? read-pos
                last-fnd-offset: str-offset
            ] [
                remove/part (skip value (fnd-offset - 1)) 1
                insert (skip value (fnd-offset - 1)) newline-sep
                last-fnd-offset: fnd-offset
                str-offset: fnd-offset
            ]
        ]
        (read-pos = "")
    ]
    return value
]
make-btns: function [
    count
] [
    loop to-integer (count / 10) [
        loop 10 [
            insert-vid-object/after/end-of-script/no-save "button" none
        ]
        append vid-code/text "^/^-return"
    ]
    run-and-save "make-buttons"
]
trun: func [
    obj-name [string!]
    num [integer!]
] [
    accum/init 0:00:00
    loop num [
        accum time-it [
            edit-vid-object obj-name "vid-code"
            close-object-editor obj-name
        ]
    ]
    probe x: accum/avg 0:00:00
    write-clipboard to-string x
]
accum: closure [
    timer-total: 0:00:00 [time!]
    count: 0 [integer!]
] [
    time-val [time!]
    /init
    /avg
] [
    if init [
        timer-total: 0:00:00
        count: 0
        exit
    ]
    if avg [
        ? timer-total
        ? count
        return (timer-total / count)
    ]
    timer-total: timer-total + time-val
    count: count + 1
    exit
]
skip-to-line: function [s line-num] [
    if line-num = 1 [return s]
    fnd-cnt: 1
    fnd-pos: s
    while [fnd-cnt < line-num] [
        either (fnd-pos: find (skip fnd-pos 1) "^/") [
            fnd-cnt: fnd-cnt + 1
        ] [
            break
        ]
    ]
    either fnd-cnt = line-num [
        return skip fnd-pos 1
    ] [
        return false
    ]
]
blank-out-comments: function [
    "Removes semi-colon comments from source code"
    source [string!]
    /line {Removes newline as well if beginning of line is only whitespace}
    /with replacement-char [char!] {replaces entire comment with this character - to maintain size and spacing}
] [
    s: copy source
    comments-found: get-comments s
    reverse/skip comments-found 2
    replacement: copy ""
    foreach [line-num comment-string] comments-found [
        if with [
            replacement: copy ""
            insert/dup replacement replacement-char (length? comment-string)
        ]
        comment-line: skip-to-line s line-num
        comment-offset: index? find comment-line comment-string
        replace comment-line comment-string replacement
        if line [
            comment-index: index? comment-line
            comment-preamble: copy/part (skip s (comment-index - 1)) (comment-offset - comment-index)
            if all-whitespace? comment-preamble [
                remove/part (skip s (comment-index - 2)) (comment-offset - comment-index + 1)
            ]
        ]
    ]
    return head s
]
set 'get-catalog-filenames function [
    /scenario
] [
    post-fix: %-style.red
    post-len: -10
    files: either scenario [
        post-fix: %-scenario.red
        post-len: -13
        read dc-scenario-catalog-path
    ] [
        read dc-style-catalog-path
    ]
    collected: collect [
        foreach file files [
            if (copy/part tail file post-len) = post-fix [
                keep file
            ]
        ]
    ]
]
split-filename: function [
    {returns a block containing [ <base-name-of-file> <file-extension> ] }
    filename [file!]
] [
    return reduce [
        to-string first split (second (split-path filename)) "."
        to-string second split (second (split-path filename)) "."
    ]
]
find-unused-filename: function [
    "returns a unique filename that does not exist"
    filename [file!]
] [
    file-path: first split-path filename
    basename-parts: split-filename filename
    count: 0
    while [
        exists? filename
    ] [
        count: count + 1
        filename: rejoin [
            file-path basename-parts/1 "-v" count "." basename-parts/2
        ]
    ]
    return filename
]
delim-extract: function [
    {V2 returns a block of every string found that is surrounded by defined delimeters}
    source-str [string!] "Text string to extract from."
    left-delim [string!] {Text string delimiting the left side of the desired string.}
    right-delim [string!] {Text string delimiting the right side of the desired string.}
    /include-delimiters "Returned extractions will include the delimiters"
    /use-head "Head of string is used as left delimiter"
    /first "Return the first match found only"
    /pairs-only {Return only fully matched pairs of delimiters. Left and right delimiter need to be the same.}
    /indexed "return offset pairs of each match"
    /local tags tag i j paired-tags
] [
    tag: ""
    tags: copy []
    if use-head [
        either include-delimiters [
            parse source-str [
                left-mark: copy tag thru right-delim right-mark:
                (
                    either indexed [
                        tag: reduce [reduce [
                            rejoin [left-delim tag right-delim]
                            to-pair reduce [((index? left-mark) - 1) (index? right-mark)]
                        ]]
                    ] [
                        insert head tag left-delim
                    ]
                )
            ]
        ] [
            parse source-str [copy tag to right-delim]
        ]
        append tags tag
    ]
    either include-delimiters [
        parse source-str [
            some [
                [thru left-delim left-mark: copy tag to right-delim right-mark:]
                (
                    either indexed [
                        append/only tags reduce [
                            rejoin [left-delim tag right-delim]
                            to-pair reduce [((index? left-mark) - 1) (index? right-mark)]
                        ]
                    ] [
                        append tags rejoin [left-delim tag right-delim]
                    ]
                )
            ]
        ]
    ] [
        parse source-str [
            some [
                [thru left-delim left-mark: copy tag to right-delim right-mark:]
                (
                    either indexed [
                        append/only tags reduce [
                            tag
                            to-pair reduce [((index? left-mark) - 1) (index? right-mark)]
                        ]
                    ] [
                        append tags tag
                    ]
                )
            ]
        ]
    ]
    either first [
        either ((length? tags) = 0) [
            return none
        ] [
            either pairs-only [
                paired-tags: copy []
                either indexed [
                    foreach [i j] (copy/part tags 2) [
                        append paired-tags i
                    ]
                ] [
                    return tags/1
                ]
                return paired-tags
            ] [
                return tags/1
            ]
        ]
    ] [
        either all [
            pairs-only
            (left-delim = right-delim)
        ] [
            paired-tags: copy []
            either indexed [
                forskip tags 2 [
                    append/only paired-tags (system/words/first tags)
                ]
                return paired-tags
            ] [
                foreach [i j] tags [
                    append paired-tags i
                ]
                return paired-tags
            ]
        ] [
            return tags
        ]
    ]
]
which-inside: function [
    a [pair!]
    b [pair!]
] [
    if inside? a b [return a]
    if inside? b a [return b]
    return none
]
overlay-string: function [
    str [string!]
    overlay [string!]
    offset [integer!]
    /with with-char [char!] "characters to use in place of overlay string"
] [
    s: copy str
    either with [
        overlay-str: copy ""
        (insert/dup overlay-str (to-string with-char) (length? overlay))
    ] [
        overlay-str: overlay
    ]
    replace s overlay overlay-str
    return s
]
locate-in-file: function [
    "returns the line and column number of the needle"
    haystack [string! file!]
    needle
] [
    if file? haystack [haystack: read haystack]
    either fnd: find haystack needle [
        fnd-part: (copy/part haystack (index? fnd))
        line-count: count-newlines fnd-part
        last-newline: char-index?/back fnd-part (length? fnd-part) #"^/"
        col-count: (index? fnd) - last-newline
        return reduce [line-count col-count]
    ] [
        return [0 0]
    ]
]
get-hilight-image: function [
    vid-object
] [
    img: to-image vid-object
    results: make image! img/size
    i: 0
    foreach p img [
        i: i + 1
        switch p [
            225.225.225.0 [p: 229.241.251.0]
            173.173.173.0 [p: 0.120.215.0]
        ]
        results/:i: p
    ]
    return results
]
duplicates: function [
    set
    /skip skip-size
] [
    results: copy set
    uni: unique set
    foreach item uni [
        if fnd: find results item [
            remove/part fnd 1
        ]
    ]
    return results
]
get-absolute-offset: function [
    face
] [
    offset-adjust: [6x6 8x31 6x26 8x51]
    adjust-index: 1
    adjustment: 0
    results: face/offset
    target: face/parent
    until [
        results: results + target/offset
        if target/type = 'window [
            if not find target/flags 'no-title [adjust-index: adjust-index + 1]
            if not none? target/menu [adjust-index: adjust-index + 2]
            adjustment: (pick offset-adjust adjust-index)
        ]
        target: target/parent
        (target/type = 'screen)
    ]
    return (results + adjustment)
]
upsert: function [
    {If a value is not found in a series, append it. Returns true if added}
    series [series!]
    value
    /only "Append block types as single values"
] [
    not none? unless find/:only series :value [insert/:only series :value]
]
set 'trim-non-char function [str [string!]] [
    trim/with str trim/with copy str {abcdefghijklmnopqrstuvwxyz~ABCDEFGHIJKLMNOPQRSTUVWXYZ -1234567890:./=?&%+$#_[]!*`}
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
clear-vid: does [
    close-object-editor/all-open
    vid-code/text: copy ""
    setup-code-undoer/set-initial-text ""
    vid-code-undoer/set-initial-text ""
    run-and-save "clear-vid"
    show-insert-tool/refresh
]
print-chars: function [
    val
    /output
] [
    results: print-each/columns/width/output val 10 6
    replace/all results {#"} ""
    replace results "'val' =" rejoin [
        {       1    2    3    4    5    6    7    8    9    10}
        newline
        {       --   --   --   --   --   --   --   --   --   --}
    ]
    replace/all results {"} " "
    if output [
        return results
    ]
    print results
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
    if not first-char: first-printable (skip value prev-newline) [return ""]
    return copy/part (skip value prev-newline) (first-char - 1)
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
        "file" [
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
    /history history-block [block!] {block containing 2 elements history-data-file and label-string for the history field}
] [
    ret-val: copy ""
    either file? current-file [
        current-path: first split-path current-file
    ] [
        current-path: system/options/path
    ]
    current-folder:
    return-val: func [/cancel /skip] [
        ret-val: 0
        if skip [
            ret-val: 'skip
        ]
        if cancel [
            ret-val: none
        ]
        if ret-val = 0 [
            ret-val: to-red-file any [file-field/text ""]
            if all [
                ret-val <> ""
                history
            ] [
                upsert history-drop-down/data (form to-local-file ret-val)
                save history-drop-down/extra/save-filename history-drop-down/data
            ]
        ]
        unview/only rre
    ]
    either skip-button [
        skip-btn: [button "SKIP" 100x24 [return-val/skip]]
    ] [
        skip-btn: [button 0x0 hidden]
    ]
    either history [
        history-line: compose/deep [
            label-inline (history-block/2)
            history-drop-down: drop-down data [] 400x24
            extra [
                save-filename: ""
            ]
            on-create [
                face/extra/save-filename: (history-block/1)
                if exists? face/extra/save-filename [
                    face/data: load/all face/extra/save-filename
                ]
            ]
            on-change [
                file-field/text: pick face/data face/selected
            ]
            return
        ]
    ] [
        history-line: [button 0x0 hidden]
    ]
    rre: layout rz: compose/deep [
        title "Select a File"
        on-close [
            ret-val: none
        ]
        style label-inline: text 120x24 230.230.230 font-color 0.0.0 right middle font-size 10
        across
        space 2x4
        text "" 120x24
        text (message) font-size 11 400x62
        return
        label-inline (prompt)
        space 1x8
        file-field: field 400x24 [
            return-val
        ]
        space 1x8
        button "^^" 24x24 [
            if file-field/text <> "" [
                current-path: first split-path to-red-file file-field/text
            ]
            if filename: request-file/title/file "Select a File" current-path [
                file-field/text: form to-local-file filename
                if history [
                    history-drop-down/selected: none
                ]
            ]
        ]
        return
        (history-line)
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
get-set-words: func [
    "returns set-word and value of a block"
    value [block!]
    /just
] [
    results-vals: copy []
    rule: [any
    [
        set-word! mark: (
            append results-vals first back mark
            if not just [append results-vals first mark]
        )
        | ahead block! into rule
        | skip
    ]]
    parse-res: parse value rule
    return results-vals
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
    value [string! pair! point2D! none!]
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
    return either any [
        (s = none)
        (s = false)
    ] [
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
    /only "Exclude head and tail newlines from removal"
    /replace "replace square bracket with spaces"
] [
    trim/head (trim/tail val)
    if all [
        ((first val) = #"[")
        ((last val) = #"]")
    ] [
        remove val
        remove back tail val
        if replace [
            insert val " "
            append val " "
        ]
    ]
    if not only [
        if ((first val) = #"^/") [remove val]
        if ((last val) = #"^/") [remove back tail val]
    ]
    return val
]
offset-to-object-name: func [
    offset [pair! point2D!]
] [
    point: offset + to-pair reduce [((splitv/offset/x + 7) * -1) (splitv/offset/y - 5)]
    result: none
    foreach-face output-panel [
        if within? point face/offset face/size [
            result: (get-object-name face)
        ]
    ]
    return result
]
get-object-name: func [
    {v3 return the name of the object or a block if /dupes }
    face
    /dupes {checks for object name duplicates. returns a block of duplicate names if dupes found}
] [
    all-vid-names: get-defined-vid-objects vid-code/text
    all-vid-names: collect [
        foreach [set-word set-type] all-vid-names [
            keep set-word
        ]
    ]
    if dupes [
        dupe: duplicates all-vid-names
        if dupe <> [] [
            return dupe
        ]
    ]
    foreach vid-name all-vid-names [
        if all [
            (value? to-word vid-name)
            (face == (get to-word vid-name))
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
    at-loc [integer!] "skip amount into each element of the array"
    find-this
    /with-index
    /within "will search within a block"
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
        if finder find-this [
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
    /local split-filename local-path local-file filename-word last-stamp call-cmd call-output file-stamp
] [
    split-file-name: split-path filename
    local-path: to-local-file split-file-name/1
    local-file: to-local-file split-file-name/2
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
